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

export SCRIPT_BASE=$1

cat >> /root/setup_data_generation.sh << EOF

yum install epel-release -y
yum install python34 python-pip -y
pip install --upgrade pip
pip install --upgrade virtualenv
cd /srv
virtualenv -p python3 hamlet
cd hamlet
source bin/activate
mkdir content
cd content
pip install requests
wget $SCRIPT_BASE/generate/hamlet_vocabulary.txt
wget $SCRIPT_BASE/generate/hamlet.py
echo "to use:"
echo "cd /srv/hamlet"
echo "source bin/activate"
echo "cd content"
echo "python /srv/hamlet/content/hamlet.py"
echo "(use CTRL-C to cancel anytime)"
export PUBLIC_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo curl \'"\$PUBLIC_IP:9200/librarygen/book/_search?q=*:*&pretty"\'
EOF
chmod +x /root/setup_data_generation.sh