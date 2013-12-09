<#
    .SYNOPSIS
    Strips all tags from an XML document that match the given XPath expression while the contents of the tag are be preserved.

    .EXAMPLE
    "<html><body><div><p><span></span></p></div></body></html>" | Strip-Tag -XPath "//p" -Output .\output.xml
#>
function Strip-Tag {
    param(
        [Parameter(Mandatory = $true)]
        [string] $XPath,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        $Xml,
        [Parameter(Mandatory = $false)]
        [string] $InputFile,
        [Parameter(Mandatory = $false)]
        [string] $OutputFile
    )

    #region Parameter Validation and Initialization

    if (-not $Xml -and -not $InputFile) {
        throw "Both `$Xml and `$Input cannot be null."
    }

    # Temporary directory and files
    $guid = [guid]::NewGuid()
    New-Item -ItemType directory -Path "${env:Temp}\$guid" | Out-Null

    $transform = "${env:Temp}\$guid\strip_tag.xsl"

    if (-not $InputFile -or $Xml) {
        # If both $Xml and $InputFile are set, then $Xml overrides $InputFile.
        # In this case, a temporary file is used so that $InputFile is not overwritten.

        $InputFile = "${env:Temp}\$guid\input.xml"
    }

    if (-not $OutputFile) {
        $OutputFile = "${env:Temp}\$guid\output.xml"
    }

    if ($Xml -is [string]) {
        $Xml = [xml] $Xml
    }

    if ($Xml -is [xml]) {
        $Xml.Save($InputFile)
    }

    #endregion
    
    # Creates XSL stylesheet for stripping tags.
    $xsl = xd {
        xe "xsl:stylesheet" -Attributes @{
            version = "1.0"
        } -Body {
            xe "xsl:template" -Attributes @{
                match = $XPath
            } -Body {
                xe "xsl:apply-templates" -Attributes @{ select = "@*" }
                xe "xsl:apply-templates" -Attributes @{ select = "*" }
            }

            # Copy template
            xe "xsl:template" -Attributes @{
                match = "@* | node()"
            } -Body {
                xe "xsl:copy" {
                    xe "xsl:apply-templates" @{ select = "@* | node()" }
                }
            }
        }
    }

    $xsl.Save($transform)
    
    # Executes XSL transformation.
    $xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
    $xslt.Load($transform)
    $xslt.Transform($InputFile, $OutputFile)

    return [xml] (Get-Content -Path $OutputFile)
}
# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoAmfuRlADIZHSXG0VkaVDv8W
# xIOgggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMzExMjYyMzIwNDhaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALdBvNI3
# j6vmeqxdtSvEvmkcKjtgmo5ctNhFkhaAxmV8CFUjtXrhZpBUd/wZVJR0SxfUKXh/
# 0zvo5miJiIst3wwc0NAZ06/ZduQxGvKgUO+u51ARldQ71iXNVbp4i5Bsf7sjEXw8
# zqsZrMSd+/IoYhokvfLQqxi3gSOc1ULxmpu7qvJ1dDWahGgfKLP1ZSodk1JYUzr8
# hPbPNJlxVpgeJbc8a3lpeNIepKFhAsyRZR4+GOBicv9vpwPT9b3whCXmqL58/U5Z
# WG7mBsrw5gT9fGdDx84dC9lWsAMxl3s6UWR8sAxj81bYtOfyVH8dc9d79fXF46f9
# vFzadOGTq4N2/skCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQTZ4y1nkWtq/8bmxPyIs8OKEuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQ7LVPQ67YLJBMwqNhj3rYBzAJBgUrDgMC
# HQUAA4IBAQAQWrc9435NyrbB/ovw8U6Ec9kISnqbsVBG7+6FpEY7nQW9ktBKyYnr
# xIXKQkBpb0UKAX/yBxcQcSyK0uqj0dpHms98xaObUg3CGpfXESme6O+G1M1oNVFj
# S5IGxS7TCri8izsELirArEX1+l+1Oc/CrQjA2Nio5VF5NWxzEgeJcrmaqum9I2Pq
# wOg0DIVRoJ2alXpfng/EIaO6BdvpQjPFeuKlrIOzi3bHkRAtOoAzymmhBfnUFEWQ
# 4DpqBzyIcBRc1E9O8IdXqgb7IG5EyM9ELpg4t5HmNKYV+k3+PxiX7L3yzCAyTOBU
# kK1myGoP3JHAjSbm11lMvC1gbE5b8l+vMYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCELOkxop64VSkSPFY
# iQVKFPcwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFGnhHE6xLLX69RvqPQ6PrRNbPIZwMA0GCSqG
# SIb3DQEBAQUABIIBAAPAY34p2C4QPzEZA/kOrr2XpliOFzQ4PanJo7ki1bhFonrt
# D+5XV+3qXBnqNqVwQndjtxaOqOWgyQiSVe3hgGPIfEhLsJpt9lRUAIksv99/7FrY
# d9V1UJb3qcIjpQApqLwhqWpFUtSkrM6mUXEbvhmbdjCwaXJeAA8cNXEXv22j+CpD
# JCsZxc62FOWGkqudFXNOj6NCAOREbRIGN5zpbIV3djSUhAup7wAUtLU8nt7ih1C4
# ZGkiZNy2l1zUIg7OBT9UV2TNOAW0uhKHIsNuYv2/YBSeRmk+4ZuCdMMByJZvaEkm
# kL9uTnHt5K1ZMUljr5rguDH6T1Gl5Ul3MZ770xE=
# SIG # End signature block
