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
    
}

certificatesForPharmacy() {
    
}

certificatesForInsProvider() {
    
}

certificatesForOrderer() {
    
}

