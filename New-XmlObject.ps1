
function New-XmlObject {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Input")]
        [object] $InputObject,

        $Attributes,

        [Parameter(Mandatory = $false)]
        [string] $SetName,
        [Parameter(Mandatory = $false)]
        [string] $ItemName,
        [Parameter(ValueFromPipeline = $true)]
        $Parent
    )

    if (-not $SetName) {
        $SetName = "ResultSet"
    }

    if (-not $ItemName) {
        $ItemName = "Item"
    }

    if ($Parent -eq $null) {
        $Parent = $_
    }

    if ($Parent -is [xml]) {
        $xmlDoc = $Parent
        $Parent = $Parent.DocumentElement
    } elseif ($Parent -is [System.Xml.XmlElement]) {
        $xmlDoc = $Parent.OwnerDocument
    } else {
        throw "Error"
    }

    if ($SetName -match "(?<prefix>.*:)?(?<tag>.+)") {
        $prefix = $matches["prefix"] -replace ":", ""
        $element = $xmlDoc.CreateElement($prefix, $matches["tag"], $Namespaces[$prefix])
    } else {
        $element = $xmlDoc.CreateElement($SetName)
    }

    if ($Parent) {
        $Parent.AppendChild($element) | Out-Null
    } else {
        # Document has no root element yet.
        $xmlDoc.AppendChild($element)
    }

    if ($Attributes) {
        $context = $_
        $_ = $element

        if ($Attributes -is [ScriptBlock]) {
            & $Attributes | Out-Null
        } elseif ($Attributes -is [object]) {
            foreach ($key in $Attributes.Keys) {
                $_ | New-XmlAttribute -Name $key -Value $Attributes[$key]
            }
        }

        $_ = $context
    }

    if ($InputObject -is [array]) {
		foreach ($obj in $InputObject) {
			$item = xe $ItemName -Parent $element {
				foreach ($prop in ($obj | Get-Member -MemberType NoteProperty)) {
					xe $prop.Name -Parent $element {
						xt ($obj | Select -ExpandProperty "$($prop.Name)")
					}
				}
			}
		}
    }

    return $element
}
# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUX041VmcQPYv3jpIJpRZYEEuc
# O56gggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFP24XM/UpUwOeXkLUbolsABR9WS8MA0GCSqG
# SIb3DQEBAQUABIIBAIm73T6eNxkTAtfPTkeEOmMSvoqTk9Cd82tephacpSBQnOY9
# 3VqogQWM9lLulsEpB2eTgGZdVecHhZrM4bAiKLnSGc3Wt4uQyCfs//OtCc5N9RrO
# kCIRFn+9MoHL+1GSj/zpEutZ/6cZHmmcc6VwJAmWMTuXUGVJMMmUuiOS1hnv7Aif
# WDObEW+JShZFQE++bU9jBh23OX+yffy02MeKzhjd3pfCCt7IohkWxUYjBOrMROYH
# Q1p3QeQYF1NjAguc0ycQKHhTzU0MkPmrK0+BwyMSukWu2+CMpii0rJ3RzPLVCxnG
# wn+Ne+lOLFEKTTFaOcFtiTij4URwN3sz0N8Or58=
# SIG # End signature block
