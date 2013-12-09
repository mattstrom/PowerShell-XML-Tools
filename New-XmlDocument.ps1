<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    New-XmlDocument -Body {
        New-XmlElement -Name "html" -Body {
            New-XmlElement -Name "head"
            New-XmlElement -Name "body"
        }
    }
#>
function New-XmlDocument {
    [CmdletBinding()]
    param(
        [Parameter(Position = 1)]
        [ScriptBlock] $Body,
        $Namespaces,

        [Parameter(Mandatory = $false, Position = 2)]
        [string] $OutputFile,

        [Parameter(Mandatory = $false)]
        [string] $AppendTo,

        [Parameter(ValueFromPipeline = $true)]
        $Input
    )

    if ($Input) {
        $xmlDoc = [xml] $Input
    } else {
        $xmlDoc = [xml] ""
    }

    if (-not $Namespaces) {
        $Namespaces = $XMLNS
    }

    if ($Body) {
        $context = $_

        if ($AppendTo) {
            $appendToNode = Select-Xml -Xml $xmlDoc -XPath $AppendTo

            if ($appendToNode) {
                foreach ($node in $appendToNode) {
                    $_ = $node.Node
                    & $Body | Out-Null
                }
            }
        } else {
            $_ = $xmlDoc
            & $Body | Out-Null
        }

        $_ = $context
    }

    if ($OutputFile) {
        $xmlDoc.Save($OutputFile)
    }

    return $xmlDoc
}

# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7d1FwExltPGY4WZhPpfjHaNO
# lhSgggNCMIIDPjCCAiqgAwIBAgIQs6TGinrhVKRI8ViJBUoU9zAJBgUrDgMCHQUA
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
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFICCXBq1G9oQJ6xH0/0T0yDlHvPYMA0GCSqG
# SIb3DQEBAQUABIIBAAeyn8UpyPjiMahcIIWdsY0uTZoLhT8SH5dP40VCDvTsZ7+M
# KfRabaEdYVFEn4zDjoLxMFJuMuGwbw/BbaLjv2HvdApOmws0B1J9IHSDyqFlA989
# tG1ZS7NZDEwkjAfu9OFpwjaVPHskAZEbL6PC/s5VMTC+XTf+aKWBuHP8lhqTr/mS
# AEVvO6cas9J3WAlDKk73Gg62vV07O1Lddr5Ab3M+oHoTEva6fwlV5+G9a30WYlLD
# 3DVLxn06pX8EHdiExejXOjU2mmQdc9VDWxssgJiwMOwY4FSCgwWF72uRVTeZ0QvB
# Hr8lRJY0ExDsc/Y/8EFoubkWz3PfF1A3xil5+bw=
# SIG # End signature block
