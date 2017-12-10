# MIT License

# Copyright(c) 2016 David Betz

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function createmesh { param([Parameter(Mandatory=$true)]$rg,
                            [Parameter(Mandatory=$true)]$key)

    function getname { param($id)
        $parts = $id.split('-')
        return $parts[$parts.length-1]
    }

    $gateways = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $rg

    ($gateways).foreach({
        $source = $_
        ($gateways).foreach({
            $target = $_
            $sourceName = getname $source.Name
            $targetName = getname $target.Name
            if($source.name -ne $target.name) {
                $connectionName = ('conn-{0}2{1}' -f $sourceName, $targetName)
                Write-Host "$sourceName => $targetName"
                New-AzureRmVirtualNetworkGatewayConnection -ResourceGroupName $rg -Location $source.Location -Name $connectionName `
                    -VirtualNetworkGateway1 $source `
                    -VirtualNetworkGateway2 $target `
                    -ConnectionType Vnet2Vnet `
                    -RoutingWeight 10 `
                    -SharedKey $key
            }
        })  
    })
}
function _virtualenv {

Add-Type -AssemblyName System.Web
$key = [System.Web.Security.Membership]::GeneratePassword(16,2)

createmesh -rg $rgGlobal -key $key

} _virtualenv