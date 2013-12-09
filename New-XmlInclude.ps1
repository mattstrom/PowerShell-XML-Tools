
function New-XmlInclude {
    param(
        [xml] $Include,

        $Body,
        $Attributes,

        [Parameter(ValueFromPipeline = $true)]
        $Parent
    )

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

    $element = $xmlDoc.CreateElement("xi", "include", $Namespaces["xi"])

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

    if ($Body) {
        $context = $_
        $_ = $element

        if ($Body -is [ScriptBlock]) {
            & $Body | Out-Null
        } elseif ($Body -is [string]) {
            $_ | New-XmlText $Body
        }

        $_ = $context
    }

    return $element
}
# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUu1zdzG92d/4+xdvgyK4RJGop
# 0IqgggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFKh9XvPtFbEzDxA+kELbEaZiDqLAMA0GCSqG
# SIb3DQEBAQUABIIBAClicyXIO8MnSn1VLaVw6aTiLqyjycgH+gwjPeRHBY9tkTlC
# QEZLjdPKlySHlm5UMpSZzeQW9C7x6Fsf8If7vaO9j7qMRGlZ4GUd3gWzKN4EcovK
# PXRnEazJ4wekqzOaWIDCmoKO1VuVxIgD87EtN+uQ/nLpi8R2Tp3c4ZfVzCndDZlm
# +0MND8V6iKrO3iPgZ3Pl6GZYxafr3UP35JGlqp/NiQ5PhJaRq78kIuq5dBxtZc7H
# eRfYAP0zrlG8H1ocm+YYzsGRE5wFOaEBez0XbeLax2Gzz1sqkGxly7abeKHH+8Wa
# n3hwxtAzWdI18AE1rBnNHPpZlyDXLTmdZa6eXwA=
# SIG # End signature block
