<#
    .SYNOPSIS
    Adds the specified attributes to all tags in an XML document that match the given XPath expression.

    .EXAMPLE
    "<html><body><div><p></p></div></body></html>" | Add-AttributesToTag -XPath "//p" -Attributes @{ class = "para" } -OutputFile .\output.xml
#>
function Add-AttributesToTag {
    param(
        [Parameter(Mandatory = $true)]
        [string] $XPath,
        [Parameter(Mandatory = $true)]
        [object] $Attributes,
        [Parameter(Mandatory = $false)]
        [switch] $Overwrite = $false,

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
    $guid = [guid]::Parse("f29d62a9-ff62-4578-b04c-2a9ab4cdfc15")
    New-Item -ItemType directory -Path "${env:Temp}\$guid" -ErrorAction Ignore | Out-Null

    $transform = "${env:Temp}\$guid\add_attributes.xsl"
    
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

    $_attributes = $Attributes

    # Creates XSL stylesheet for renaming tags.
    $xsl = xd {
        xe "xsl:stylesheet" -Attributes @{
            version = "1.0"
        } -Body {
            xe "xsl:param" -Attributes @{
                name = "overwrite"
                select = @{ $true = "true()"; $false = "false()" }[$Overwrite.IsPresent]
            }
            xe "xsl:template" -Attributes @{
                match = $XPath
            } -Body {
                xe "xsl:copy" -Body {
                    foreach ($attr in $_attributes.Keys) {
                        xe "xsl:choose" {
                            xe "xsl:when" -Attributes @{
                                test = "`$overwrite or (not(`$overwrite) and not(./@$attr))"
                            } -Body {
                                xe "xsl:attribute" -Attributes @{ name = $attr } -Body {
                                    xt $_attributes[$attr]
                                }                                
                                xe "xsl:apply-templates" -Attributes @{ select = "@*[local-name() != '$attr']" }
                            }
                            xe "xsl:otherwise" {
                                xe "xsl:apply-templates" -Attributes @{ select = "@*" }
                            }
                        }
                    }
                    xe "xsl:apply-templates" -Attributes @{ select = "*" }
                }
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoxQMWizZvJNLcCCSM500v08s
# qyOgggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFEuxaF+BcdjfamsJSXAkPA0GPmjmMA0GCSqG
# SIb3DQEBAQUABIIBACZozU8220Ut0jXHiduk/9BFl5kFCYsYEeg11jIQueT02LEN
# hxnlJF3UE9WoP4+BZpye484r+e3ECfzhIOtVnixILLZyGiPGZQDpQrQxtobwn0Lk
# mqj3+C31bcUHqyqKeefc2PChnc8Cbu7TikQ7fq8lNTkuqmIWBQty1kz6fl38kM/u
# Q8cRmh5EsJYabsNLFCFeFlhH0gAg0ggBa5aT/GwDS04nx+AIc5Oa5b6g0rE/mG1/
# fVdzF5jcpJAJ9JFoU8vL3bnGHw0lqjIANR06ftmIvQnFcLMfWLIza+SOjhfpQsSc
# SuE4Ktyl6BcCzfpgmOpF3aAfhgxK/bMTQkPEoNM=
# SIG # End signature block
