<#
    .SYNOPSIS
    Surrounds all tags in an XML document that match the given XPath expression with the specified parent tag.

    .EXAMPLE
    "<html><body><div><p><span></span></p></div></body></html>" | Surround-Tag -XPath "//p" -WithTag "div" -Output .\output.xml
#>
function Surround-Tag {
    param(
        [Parameter(Mandatory = $true)]
        [string] $XPath,
        [Parameter(Mandatory = $true)]
        [string] $WithTag,
        [Parameter(Mandatory = $false)]
        [object] $Attributes,

        [Parameter(Mandatory = $false)]
        [switch] $AsSet,
        [Parameter(Mandatory = $false)]
        [string[]] $Siblings,

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
    $guid = [guid]::Parse("3cc23253-9461-42c8-9671-15fbff3ed28f")
    New-Item -ItemType directory -Path "${env:Temp}\$guid" -ErrorAction Ignore | Out-Null

    $transform = "${env:Temp}\$guid\surround_tag.xsl"

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

    if ($AsSet) {
        $Siblings = @("li") + $Siblings

        $siblingsXPath = ($Siblings | %{ "child::$_" }) -join "|"
    }

    # Creates XSL stylesheet for stripping tags.
    $xsl = xd {
        xe "xsl:stylesheet" -Attributes @{
            version = "1.0"
        } -Body {
            xe "xsl:param" -Attributes @{ name = "mode" } -Body {
                xt @{ $true = "Set"; $false = "Item" }[$AsSet.IsPresent]
            }

            #region Root template
            xe "xsl:template" -Attributes @{ match = "/" } -Body {
                xe "xsl:if" -Attributes @{ test = "`$mode = 'Item'" } -Body {
                    xe "xsl:apply-templates" -Attributes @{ mode = "Item" }
                }
                xe "xsl:if" -Attributes @{ test = "`$mode = 'Set'" } -Body {
                    xe "xsl:apply-templates" -Attributes @{ mode = "Set" }
                }
            }
            #endregion

            #region Item-mode Template
            xe "xsl:template" -Attributes @{
                match = $XPath; mode = "Item"
            } -Body {
                xe "xsl:element" -Attributes {
                    xa "name" $WithTag
                    foreach ($attr in $_attributes.Keys) {
                        xa -Name $attr -Value $_attributes[$attr]
                    }
                } -Body {
                    xe "xsl:copy" {
                        xe "xsl:apply-templates" -Attributes @{ select = "@*" }
                        xe "xsl:apply-templates" -Attributes @{ select = "*" }
                    }
                }
            }
            #endregion

            #region Set-mode Template
            
            $xp = $XPath -replace "//", ""

            xe "xsl:template" -Attributes @{
                match = "//*[$xp]"; mode = "Set"
            } -Body {
                xe "xsl:copy" {
                    xe "xsl:element" -Attributes {
                        xa "name" $WithTag
                        foreach ($attr in $_attributes.Keys) {
                            xa -Name $attr -Value $_attributes[$attr]
                        }
                    } -Body {
                        xe "xsl:for-each" -Attributes @{ select = $siblingsXPath } -Body {
                            xe "xsl:copy" {
                                xe "xsl:apply-templates" -Attributes @{ mode = "Set" }
                            }
                        }
                    }
                }
            }
            #endregion

            #region Item-mode copy template
            xe "xsl:template" -Attributes @{
                match = "@* | node()"; mode = "Item"
            } -Body {
                xe "xsl:copy" {
                    xe "xsl:apply-templates" -Attribute @{ select = "@* | node()"; mode = "Item" }
                }
            }
            #endregion

            #region Set-mode copy template
            xe "xsl:template" -Attributes @{
                match = "@* | node()"; mode = "Set"
            } -Body {
                xe "xsl:copy" {
                    xe "xsl:apply-templates" -Attributes @{ select = "@* | node()"; mode = "Set" }
                }
            }
            #endregion
        }
    }

    $xsl.Save($transform)
    
    # Executes XSL transformation.
    $xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
    $xslt.Load($transform)
    $xslt.Transform($InputFile, $OutputFile)

    return [xml] (Get-Content -Path $OutputFile)
}

@"
<html>
	<body>
		<li>Item 1</li>
		<li>Item 2</li>
		<li>Item 3</li>
		<div>Div 1</div>
	</body>
</html>
"@ | Surround-Tag -XPath "//li" -WithTag "ul" -Siblings @("li", "div") -AsSet -Output .\output.xml
# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzp+qtgcFvq5l2RhDaKWc3qgf
# fDOgggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFNMn1e7QciZXOuvPk2+w+nKwdBlGMA0GCSqG
# SIb3DQEBAQUABIIBABR5PnB9XNDaE7e4Q+Krv4AP+FpemcWED0chlTMTD80RATU5
# 81vMH+N33c7v7n7SWsgaS+xp1s3vncISgtOtPbL22Rp+GS56tl4ztm24qQHYRcTI
# OzlPtj5NeNyqJdHujIYGDx7DjIvXWrj5EC2mNHu2Ev+tfLSHEb1EQokVwak7tsRr
# 4yky6bWstEZX0YC1GxQ2UMK11YtuBl25Qk0ICBUO/EfpPTytO1MfK/9VA4fdpObw
# 1QcKAq1x4PIUksodsfCRK93S0NFRBKTst8brnD7mNdouyqCVHRgf8qc4fnSnwcI9
# +I7CxrIwSjDoOG4g1V7JkXOIio/vBsLubtLggBY=
# SIG # End signature block
