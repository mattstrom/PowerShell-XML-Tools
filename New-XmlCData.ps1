function New-XmlCData {
    param(
        [Parameter(Mandatory = $true)]
        $Data,

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

    $cdataNode = $xmlDoc.CreateCDataSection($Data)
    $Parent.AppendChild($cdataNode) | Out-Null

    return $Parent
 }
# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3PH1ID2NoHDkPvml1T7C07GR
# RoygggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFL/nw7dGAkMasJpQtXZgYCCew/gXMA0GCSqG
# SIb3DQEBAQUABIIBABBaBfd/oUw/jSWvD2CiFIsOFhxa+Xe6oTGCLnzXDkmeXigY
# gdXG6T+4PdHasJRoUFrF0EmUa+W0gqoCnK2H8IKZIP1S6uo3b5r/KfF1e5wz+duK
# K8IRf/GRmw3xAnjhFAvT3/8tqzDeR1oPwIvckLDxT54HBlVZmd4lDzo9iVUdhimx
# C+SrLUWFw+kii000vxIcfOath89qa6Bu8OzPjoDo6QubRTNBLJlatgM2a5qFRmC2
# Nch6PCPJKEGdRdszV24BM3HmD3uzIOkcjmukWkGR0kwLzj752mPTM3WaN1CXXvyU
# AyggOUD7HVFjanZqvgjfhmpdJuRK7Dao0gMrRac=
# SIG # End signature block
