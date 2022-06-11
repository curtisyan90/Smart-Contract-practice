/*
    !!!! New in StudentData v2 !!!!
        - User can change their own data.
        - Can get the amount of data.
        - Sort index when delete data.

    Bug fix
        - Check if data exists when creating data.
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.13;

contract StudentData{

    address owner;

    struct Data{
        uint id; string stdid; string phone; string mail; address addr;
    // | index |  student ID  | phone number |   mail   | wallet address |
    }

    mapping(address=>uint) AddrtoId; //Find id from address
    mapping(string=>Data) StdtoData; //Find data from stdid
    mapping(uint=>string) IdtoStdid; //Find stdid from id

    modifier onlyOwner() { //函數建構子
        require(msg.sender == owner, "not owner"); //檢查執行者是不是合約owner
        _; //執行後續程式
    }

    //get contract owner
    constructor (address initOwner) { //宣告建構式
        owner = initOwner;
        //owner = msg.sender;
    }
    uint idnum;

    //create new data
    function ceateData(string memory nstdid, string memory nphone, string memory nmail, address naddr) public onlyOwner{ //宣告函數
        require(StdtoData[nstdid].id == 0, "StudentID exist"); // check if data exists
        idnum++; // count index number
        AddrtoId[naddr] = idnum; // mapping address to index
        IdtoStdid[idnum] = nstdid; // mapping index to student id
        StdtoData[nstdid] = Data(idnum,nstdid,nphone,nmail,naddr); // add data
    }

    //find id by student id
    function findIdbyStdid(string memory nstdid) public view returns (uint id){ //宣告函數
        require(StdtoData[nstdid].id != 0, "StudentID not Found"); // check student id exists or not
        id = StdtoData[nstdid].id; // get id from mapping
    }

    //find id by address
    function findIdbyAddr(address naddr) public view returns (uint id){ //宣告函數
        require(AddrtoId[naddr] != 0, "Address not Found"); // check address exists or not
        id = AddrtoId[naddr]; // get id from mapping
    }

    //view data by index
    function readDatabyId(uint nid) public view returns (string memory rstdid, string memory rphone, string memory rmail, address raddr){ //宣告函數
        require(StdtoData[IdtoStdid[nid]].id != 0, "Data not Found"); // check data exists or not
        return(IdtoStdid[nid],StdtoData[IdtoStdid[nid]].phone,StdtoData[IdtoStdid[nid]].mail,StdtoData[IdtoStdid[nid]].addr); // return data
    }

    //view data by student id
    function readDatabyStdid(string memory nstdid) public view returns (string memory rstdid, string memory rphone, string memory rmail, address raddr){ //宣告函數
        require(StdtoData[nstdid].id != 0, "Data not Found"); // check data exists or not
        return(nstdid,StdtoData[nstdid].phone,StdtoData[nstdid].mail,StdtoData[nstdid].addr); // return data
    }

    // update data
    function updateData(string memory nstdid, string memory nphone, string memory nmail, address naddr) public { //宣告函數
        require(StdtoData[nstdid].id != 0, "StudentID not Found"); // check student id exists or not
        require(msg.sender == StdtoData[nstdid].addr || msg.sender == owner, "not owner"); // check sender address

        delete AddrtoId[StdtoData[nstdid].addr];
        StdtoData[nstdid] = Data(StdtoData[nstdid].id, nstdid, nphone, nmail, naddr); // write new data
        AddrtoId[naddr]=StdtoData[nstdid].id;
    }

    // delete data
    function deleteData(string memory nstdid) public onlyOwner{ //宣告函數
        require(StdtoData[nstdid].id != 0, "StudentID not Found"); // check student id exists or not
        idnum--;

        uint i=StdtoData[nstdid].id;
        delete IdtoStdid[StdtoData[nstdid].id];
        delete AddrtoId[StdtoData[nstdid].addr];
        delete StdtoData[nstdid];
        
        // sort data index
        for ( i ; i<=idnum ; i++){
            
            AddrtoId[StdtoData[IdtoStdid[i+1]].addr]=i;
            StdtoData[IdtoStdid[i+1]]=Data(i, StdtoData[IdtoStdid[i+1]].stdid, StdtoData[IdtoStdid[i+1]].phone, StdtoData[IdtoStdid[i+1]].mail, StdtoData[IdtoStdid[i+1]].addr);
            IdtoStdid[i]=IdtoStdid[i+1];
            
            //StdtoData[IdtoStdid[i]] = Data(i+1,StdtoData[IdtoStdid[i+1]].stdid,StdtoData[IdtoStdid[i+1]].phone,StdtoData[IdtoStdid[i+1]].mail,StdtoData[IdtoStdid[i+1]].addr); // change mapping and data
            
            if (i==idnum){
                delete StdtoData[IdtoStdid[i+2]]; // delete mapping
                delete IdtoStdid[i+2]; // delete mapping
                delete AddrtoId[StdtoData[IdtoStdid[i+2]].addr]; // delete mapping
            }
        }
    }

    // get data amount
    function dataAmount() public view returns(uint amount){
        return amount=idnum;
    }
}