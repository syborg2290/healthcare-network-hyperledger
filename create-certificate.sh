# To interact with Fabric-CA Server, we need another tool on our side. It can be either a Fabric CA client or Fabric SDKs.
# Generate crypto materials.

# 1. Bring up the Fabric-CA Server which is used as the CA of that organization.
# 2. Use Fabric-CA Client to enroll a CA Admin.
# 3. With the CA Admin, use Fabric-CA client to register and enroll every entity (peer, orderer, user, etc) one by one to Fabric-CA server.
# 4. Move the result material to directory structure.

source scriptUtills.sh
export PATH=${PWD}/../bin:$PATH

certificatesForHospital() {
    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/hospital/

    # To go back the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u http://admin:adminpw@localhost:1010 --caname ca.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    # create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1010-ca-hospital.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml            
    
    echo
    echo "Register peer0"
    echo 
    fabric-ca-client register --caname ca.hospital --id.name peer0 --id.secret peer0pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register peer1"
    echo 
    fabric-ca-client register --caname ca.hospital --id.name peer1 --id.secret peer1pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register user"
    echo 
    fabric-ca-client register --caname ca.hospital --id.name user1 --id.secret user1pw --id.type client --tls.certifiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo
    echo "Register the org admin"
    echo 
    fabric-ca-client register --caname ca.hospital --id.name hospitaladmin --id.secret hospitaladminpw --id.type admin --tls.certifiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem


    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers

    #################################################################################################
    # peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp --csr.hosts peer0.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/config.yaml   


    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls --enrollment.profile tls --csr.hosts peer0.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca/ca.hospital-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca/

    ####################################################################################################################

    # peer1 

    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/msp --csr.hosts peer1.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/msp/config.yaml   


    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls --enrollment.profile tls --csr.hosts peer1.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.key


    #########################################################################################################################################


    mkdir -p consortium/crypto-config/peerOrganizations/hospital/users
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/users/User1

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/User1/msp --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem


    mkdir -p consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://admin:adminpw@localhost:1010 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp/config.yaml   


}

certificatesForLaboratory() {

    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/laboratory/

    # To go back the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u http://admin:adminpw@localhost:1020 --caname ca.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    # create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1020-ca-laboratory.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml            
    
    echo
    echo "Register peer0"
    echo 
    fabric-ca-client register --caname ca.laboratory --id.name peer0 --id.secret peer0pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    echo
    echo "Register peer1"
    echo 
    fabric-ca-client register --caname ca.laboratory --id.name peer1 --id.secret peer1pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    echo
    echo "Register user"
    echo 
    fabric-ca-client register --caname ca.laboratory --id.name user1 --id.secret user1pw --id.type client --tls.certifiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    echo
    echo "Register the org admin"
    echo 
    fabric-ca-client register --caname ca.laboratory --id.name laboratoryadmin --id.secret laboratoryadminpw --id.type admin --tls.certifiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem


    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/peers

    #################################################################################################
    # peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/msp --csr.hosts peer0.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/msp/config.yaml   


    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls --enrollment.profile tls --csr.hosts peer0.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/tlsca/tlsca.laboratory-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer0.laboratory/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/ca/ca.laboratory-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/ca/

    ####################################################################################################################

    # peer1 

    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/msp --csr.hosts peer1.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/msp/config.yaml   


    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls --enrollment.profile tls --csr.hosts peer1.laboratory --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/peers/peer1.laboratory/tls/server.key


    #########################################################################################################################################


    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/users
    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/users/User1

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/users/User1/msp --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem


    mkdir -p consortium/crypto-config/peerOrganizations/laboratory/users/Admin@laboratory

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://admin:adminpw@localhost:1020 --caname ca.laboratory -M ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/users/Admin@laboratory/msp --tls.certfiles ${PWD}/consortium/fabric-ca/laboratory/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/laboratory/users/Admin@laboratory/msp/config.yaml   


    
}

certificatesForPharmacy() {


    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/

    # To go back the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u http://admin:adminpw@localhost:1030 --caname ca.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    # create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1030-ca-pharmacy.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1030-ca-pharmacy.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1030-ca-pharmacy.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1030-ca-pharmacy.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml            
    
    echo
    echo "Register peer0"
    echo 
    fabric-ca-client register --caname ca.pharmacy --id.name peer0 --id.secret peer0pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    echo
    echo "Register peer1"
    echo 
    fabric-ca-client register --caname ca.pharmacy --id.name peer1 --id.secret peer1pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    echo
    echo "Register user"
    echo 
    fabric-ca-client register --caname ca.pharmacy --id.name user1 --id.secret user1pw --id.type client --tls.certifiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    echo
    echo "Register the org admin"
    echo 
    fabric-ca-client register --caname ca.pharmacy --id.name pharmacyadmin --id.secret pharmacyadminpw --id.type admin --tls.certifiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem


    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/peers

    #################################################################################################
    # peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1030 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp --csr.hosts peer0.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp/config.yaml   


    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1030 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls --enrollment.profile tls --csr.hosts peer0.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/tlsca/tlsca.pharmacy-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/ca/ca.pharmacy-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/ca/

    ####################################################################################################################

    # peer1 

    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1030 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/msp --csr.hosts peer1.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/msp/config.yaml   


    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1030 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls --enrollment.profile tls --csr.hosts peer1.pharmacy --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/server.key


    #########################################################################################################################################


    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/users
    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/users/User1

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1030 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/users/User1/msp --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem


    mkdir -p consortium/crypto-config/peerOrganizations/pharmacy/users/Admin@pharmacy

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://admin:adminpw@localhost:1030 --caname ca.pharmacy -M ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/users/Admin@pharmacy/msp --tls.certfiles ${PWD}/consortium/fabric-ca/pharmacy/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/pharmacy/users/Admin@pharmacy/msp/config.yaml   

    
}

certificatesForInsProvider() {


    echo
    echo "Enroll the CA admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/insProvider/

    # To go back the previous folder
    # echo "${PWD%/[^/]*}"

    fabric-ca-client enroll -u http://admin:adminpw@localhost:1040 --caname ca.insProvider --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    # create a config.yaml file to enable the OU identifiers,
    # and keep the OU identifiers for each type of entity.
    # They are peer, orderer, client and admin.
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-insProvider.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-insProvider.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-insProvider.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-1040-ca-insProvider.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/config.yaml            
    
    echo
    echo "Register peer0"
    echo 
    fabric-ca-client register --caname ca.insProvider --id.name peer0 --id.secret peer0pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    echo
    echo "Register peer1"
    echo 
    fabric-ca-client register --caname ca.insProvider --id.name peer1 --id.secret peer1pw --id.type peer --tls.certifiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    echo
    echo "Register user"
    echo 
    fabric-ca-client register --caname ca.insProvider --id.name user1 --id.secret user1pw --id.type client --tls.certifiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    echo
    echo "Register the org admin"
    echo 
    fabric-ca-client register --caname ca.insProvider --id.name insProvideradmin --id.secret insProvideradminpw --id.type admin --tls.certifiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem


    # Create a directory for peers
    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/peers

    #################################################################################################
    # peer 0
    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1040 --caname ca.insProvider -M ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/msp --csr.hosts peer0.insProvider --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/msp/config.yaml   


    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1040 --caname ca.insProvider -M ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls --enrollment.profile tls --csr.hosts peer0.insProvider --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/server.key

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/tlscacerts/ca.crt

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/tlsca/tlsca.insProvider-cert.pem

    mkdir ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer0.insProvider/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/ca/ca.insProvider-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/ca/

    ####################################################################################################################

    # peer1 

    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider

    echo
    echo "## Generate the peer1 msp"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1040 --caname ca.insProvider -M ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/msp --csr.hosts peer1.insProvider --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/msp/config.yaml   


    echo
    echo "## Generate the peer1-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1040 --caname ca.insProvider -M ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls --enrollment.profile tls --csr.hosts peer1.insProvider --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls/server.crt   
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/peers/peer1.insProvider/tls/server.key


    #########################################################################################################################################


    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/users
    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/users/User1

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@localhost:1040 --caname ca.insProvider -M ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/users/User1/msp --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem


    mkdir -p consortium/crypto-config/peerOrganizations/insProvider/users/Admin@insProvider

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://admin:adminpw@localhost:1040 --caname ca.insProvider -M ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/users/Admin@insProvider/msp --tls.certfiles ${PWD}/consortium/fabric-ca/insProvider/tls-cert.pem

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insProvider/users/Admin@insProvider/msp/config.yaml   

    
}

certificatesForOrderer() {
    
}

