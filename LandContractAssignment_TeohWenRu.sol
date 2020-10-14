pragma solidity ^0.5.11;

contract LandContract
{
    //This contract is used for adding a property, transaction of a property title, obtain information of properties 
    



    // State Variables
    
    address public admin; 
    
    uint public totalLandsCounter; 
    
    enum PropertyStatus {Pending, Sold, Bought}                  // Propertystatus of Pending -> Available for sale, Sold -> Property no longer belong to this Owner, Bought -> Property not up for sale but belong to this Owner
    PropertyStatus propertystatus;
    PropertyStatus constant defaultPropertyStatus = PropertyStatus.Pending;
    
    struct land 
    {
     uint PropertyId;
     uint PropertyValue;
     string PropertyAddress;
     PropertyStatus propertystatus;
    }

    mapping (address => land[]) public Ownedlands;
    
    // Ownedlands[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4][0] -> PropertyId1,PropertyValue,PropertyAddress,propertystatus
    // Ownedlands[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4][1] -> PropertyId2,PropertyValue,PropertyAddress,propertystatus
    // Ownedlands[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4][2] -> PropertyId3,PropertyValue,PropertyAddress,propertystatus
    
    uint[] public PropertyPending;




    //Constructor - defining value for variables when contract is first created
    
    constructor() public
    {
        totalLandsCounter = 0;                  // Initialise the counter to start from 0 
        admin = msg.sender;                     // This sets the address which deploys the contract to be the admin
    }
    



    //Modifier

    modifier isAdmin                            // This modifier is used wherever we want admin to be the only one with access
    {
        require (msg.sender == admin);      
        _;
    }
    
    
    
    
    // Events

    event Add(address propertyOwner, uint PropertyId, uint PropertyValue, string PropertyAddress, PropertyStatus propertystatus);

    event propertyinfo(PropertyStatus _PropertyStatus, uint PropertyValue, string PropertyAddress);




    // Functions
    
    function getNumberOfLands() public view returns(uint)
    {
        return totalLandsCounter;
    }
    



    function addLand(address _propertyOwner, uint _PropertyValue, string memory _PropertyAddress) public isAdmin                //Add property to a property owner
    {
        totalLandsCounter = totalLandsCounter + 1;                                                              // totalLandsCounter is used as a running counter to assign PropertyId
        land memory myland = land(                                                                              // temporary struc land to store values based on input
            {
                PropertyId: totalLandsCounter,
                PropertyValue: _PropertyValue,
                PropertyAddress: _PropertyAddress,
                propertystatus: PropertyStatus.Pending                                                          // propertystatus of Pending is set as default whenever property is added
            });

            Ownedlands[_propertyOwner].push(myland);                                                            // Map the temporary struc information to mapping based on propertyOwner address
            
            emit Add(_propertyOwner, totalLandsCounter, _PropertyValue, _PropertyAddress, propertystatus);      //trigger event to output property info added
    }
    



    function getContainsLandId(address _propertyOwner, uint _PropertyId) internal view returns (bool)           // Boolean output to check if a particular property exist based on propertyOwner address and PropertyId
    {
        for (uint i = 0; i < Ownedlands[_propertyOwner].length; i++)                                            // using a for loop to loop through _propertyOwner array to check if _PropertyId matches with PropertyId
        {
            if (Ownedlands[_propertyOwner][i].PropertyId == _PropertyId)                                        // if given land ID is indeed in owner's collection
            {
                return true;                                                                                    // give an output of true and end for loop
            }
        }
        return false;                                                                                           // if we still did not get return, return output false       
    }
    



    function buyland(uint _PropertyId, address _propertyOwner, address _propertyBuyer) public isAdmin           // Used for transferring property ownership from _propertyOwner to _propertyBuyer
    {
        require (_propertyOwner != _propertyBuyer);                                                             // require that the _propertyOwner and _propertyBuyer are of different address
        
        uint i = 0;                                                                                             // initialise variable i to be 0
        while (Ownedlands[_propertyOwner][i].PropertyId != _PropertyId)                                         // while loop to search for the index of _propertyOwner array's PropertyId that matches with the _PropertyId
        {
            i++;
        }
        
        require (Ownedlands[_propertyOwner][i].propertystatus == PropertyStatus.Pending);                       // once index is found, use that to confirm that the propertystatus is Pending, otherwise not able to transact
        
        land memory myland = land(                                                                              // temporary struc land to store values for _propertyBuyer, the new owner
            {
                PropertyId: _PropertyId,
                PropertyValue: Ownedlands[_propertyOwner][i].PropertyValue, 
                PropertyAddress: Ownedlands[_propertyOwner][i].PropertyAddress,
                propertystatus: PropertyStatus.Bought                                                           // change property status to Bought for new owner (_propertyBuyer)
            });
            Ownedlands[_propertyOwner][i].propertystatus = PropertyStatus.Sold;                                 // change propertystatus to Sold for old owner (_propertyOwner)
            Ownedlands[_propertyBuyer].push(myland);                                                            // Map the temporary struc information to mapping for new owner (_propertyBuyer) address
            
            emit Add(_propertyBuyer, _PropertyId, Ownedlands[_propertyOwner][i].PropertyValue, Ownedlands[_propertyOwner][i].PropertyAddress, PropertyStatus.Bought);    //trigger event to output property info added
    }
    
    

    
    function getallpending(address _propertyOwner) public returns (uint[] memory)                               // return an array of all the PropertyId that have propertystatus Pending
    {
    delete PropertyPending;                                                                                     // Empty Array each time function is called
    
        for (uint i = 0; i < Ownedlands[_propertyOwner].length; i++)                                            // for loop to loop through Ownedlands array based on _OwnerAddress
        {
            // if given land ID is indeed in owner's collection
            if (Ownedlands[_propertyOwner][i].propertystatus == PropertyStatus.Pending)                         
            {
             PropertyPending.push(Ownedlands[_propertyOwner][i].PropertyId);                                    // push PropertyId to PropertyPending array if the propertystatus is Pending
            }
        }
        return PropertyPending;                                                                                 // return PropertyPending array when for loop is completed
    }
    

    
    
    function getpropertyinfo(address _propertyOwner, uint _PropertyId) public                                   // Obtain property info based on _propertyOwner address and _PropertyId
    {
        require (getContainsLandId(_propertyOwner, _PropertyId) == true);                                       // making sure _PropertyId belongs to _propertyOwner
        
        uint i = 0;                                                                                             // initialise variable i to be 0
        while (Ownedlands[_propertyOwner][i].PropertyId != _PropertyId)                                         // while loop to search for the index of _propertyOwner array's PropertyId that matches with the _PropertyId
        {
            i++;
        }  
            emit propertyinfo(Ownedlands[_propertyOwner][i].propertystatus, Ownedlands[_propertyOwner][i].PropertyValue, Ownedlands[_propertyOwner][i].PropertyAddress);   // trigger event propertyinfo to output property info
    }
    



    function editproperty (address _propertyOwner, uint _PropertyId, uint _NewPropertyValue) public isAdmin     // change the PropertyValue to _NewPropertyValue of a given PropertyId based on _propertyOwner and _PropertyId input  
    {
        require (getContainsLandId(_propertyOwner, _PropertyId) == true);                                       // making sure _PropertyId belongs to _propertyOwner otherwise do not proceed
        
        uint i = 0;
        while (Ownedlands[_propertyOwner][i].PropertyId != _PropertyId)                                         // while loop to search for the index of _propertyOwner array's PropertyId that matches with the _PropertyId
        {
            i++;
        }
        require (Ownedlands[_propertyOwner][i].propertystatus != PropertyStatus.Sold);                          // if the propertystatus is Sold it means the property no longer belong to _propertyOwner, do not proceed
        Ownedlands[_propertyOwner][i].PropertyValue = _NewPropertyValue;                                        // replace old PropertyValue with _NewPropertyValue
    }
    



    function putupforsale (address _propertyOwner, uint _PropertyId) public isAdmin                             // change the propertystatus to Pending of a given PropertyId based on _propertyOwner and _PropertyId input  
    {
        require (getContainsLandId(_propertyOwner, _PropertyId) == true);                                       // making sure _PropertyId belongs to _propertyOwner otherwise do not proceed
        
        uint i = 0;
        while (Ownedlands[_propertyOwner][i].PropertyId != _PropertyId)                                         // while loop to search for the index of _propertyOwner array's PropertyId that matches with the _PropertyId
        {
            i++;
        }

        require (Ownedlands[_propertyOwner][i].propertystatus != PropertyStatus.Sold);                          // if the propertystatus is Sold it means the property no longer belong to _propertyOwner, do not proceed

        Ownedlands[_propertyOwner][i].propertystatus = PropertyStatus.Pending;                                  // Update the property to Pending
    }
}
