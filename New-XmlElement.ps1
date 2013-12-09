
function New-XmlElement {
    param(
        [string] $Name,

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

    if ($Name -match "(?<prefix>.*:)?(?<tag>.+)") {
        $prefix = $matches["prefix"] -replace ":", ""
        $element = $xmlDoc.CreateElement($prefix, $matches["tag"], $Namespaces[$prefix])
    } else {
        $element = $xmlDoc.CreateElement($Name)
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYuzkUm/biQvBrMhhWdnn1BVJ
# M4SgggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFAq0/gNXpV9K+flq9p7JwCeGMjp2MA0GCSqG
# SIb3DQEBAQUABIIBACFeTQcT1h64Yw3Tkh75LUFnXnPvBEr66XC9ATHUjd9zvC0V
# Uzf+Eoo1GOgyWd4yzfBj9gd3VlwuArtmxojjXdBvjAVnMnnoXzMk4ZBjQD1o7GDN
# C8nLvtyaW7+DijkHQcBqNw4f2PszdYv7JdDvsDUmFFSPvelfcetUra6eZKQjsNzn
# ek3aIs7val8TqHrOsmpS4cvGspIUBSALcx/avGnRacsBaV8CpVpQduLpR/eosEgx
# m12JVqLU902gd9wvY1dPJtPM2mgHFgIqKw62qwT0DGrN29UDr9magf0T6O3UJMzO
# X1J7xKKwTaH6slS6dUgMJRHoctLJhJWDiQhMRHU=
# SIG # End signature block
