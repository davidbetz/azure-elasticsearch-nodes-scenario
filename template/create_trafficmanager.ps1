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

function createtrafficmanager { param([Parameter(Mandatory=$true)]$rg,
                                      [Parameter(Mandatory=$true)]$count)
        
    $names = @("alpha", "beta", "gamma", "delta", "epsilon")

    $uniqueName = (Get-AzureRmStorageAccount -ResourceGroupName $rg)[0].StorageAccountName

    $tmProfile = New-AzureRmTrafficManagerProfile -ResourceGroupName $rg -name "tm-$rg" `
                    -TrafficRoutingMethod Performance `
                    -ProfileStatus Enabled `
                    -RelativeDnsName $uniqueName `
                    -Ttl 30 `
                    -MonitorProtocol HTTP `
                    -MonitorPort 9200 `
                    -MonitorPath "/"

    (1..$count).foreach({
        $name = $names[$_ - 1]
        $pip = Get-AzureRmPublicIpAddress -ResourceGroupName $rg -Name "pip-$name"
        Add-AzureRmTrafficManagerEndpointConfig -TrafficManagerProfile $tmProfile -EndpointName $name -TargetResourceId $pip.id -Type AzureEndpoints -EndpointStatus Enabled
    })
    Set-AzureRmTrafficManagerProfile -TrafficManagerProfile $tmProfile
    
}

createtrafficmanager -rg $rgGlobal -count 3
