// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.13;

contract StudentData{

    address owner;

    struct Data{
        uint id; string stdid; string phone; string mail; address addr;
    // | Index |  Student ID  | Phone number |   Mail   | Wallet Address |
    }

    mapping(address=>uint) AddrtoData; // Mapping data from address
    mapping(string=>Data) StdtoData; // Mapping data from stdid
    mapping(uint=>string) IdtoStdid; // Mapping stdid from iid

    modifier onlyOwner() { //函數建構子
        require(msg.sender == owner, "not owner"); //檢查執行者是不是合約owner
        _; //執行後續程式
    }

    //get contract owner
    constructor ( address initOwner) { //宣告建構式
        owner = initOwner;
    }
    uint idnum;

    //create new data
    function ceateData(string memory nstdid, string memory nphone, string memory nmail, address naddr) public onlyOwner{ //宣告函數
        idnum++;
        AddrtoData[naddr] = idnum;
        IdtoStdid[idnum] = nstdid;
        StdtoData[nstdid] = Data(idnum,nstdid,nphone,nmail,naddr);
    }

    //find id by student id
    function findIdbyStdid(string memory nstdid) public view returns (uint id){ //宣告函數
        require(StdtoData[nstdid].id != 0, "StudentID not Found");
        id = StdtoData[nstdid].id;
    }

    //find id by address
    function findIdbyAddr(address naddr) public view returns (uint id){ //宣告函數
        require(AddrtoData[naddr] != 0, "Address not Found");
        id = AddrtoData[naddr];
    }

    //view data by id
    function readDatabyId(uint nid) public view returns (string memory rstdid, string memory rphone, string memory rmail, address raddr){ //宣告函數
        require(StdtoData[IdtoStdid[nid]].id != 0, "Data not Found");
        rstdid = IdtoStdid[nid]; rphone = StdtoData[IdtoStdid[nid]].phone;
        rmail = StdtoData[IdtoStdid[nid]].mail; raddr = StdtoData[IdtoStdid[nid]].addr;
    }

    //view data by student id
    function readDatabyStdid(string memory nstdid) public view returns (string memory rstdid, string memory rphone, string memory rmail, address raddr){ //宣告函數
        require(StdtoData[nstdid].id != 0, "Data not Found");
        rstdid = nstdid; rphone = StdtoData[nstdid].phone;
        rmail = StdtoData[nstdid].mail; raddr = StdtoData[nstdid].addr;
    }

    // update data
    function updateData(string memory nstdid, string memory nphone, string memory nmail, address naddr) public onlyOwner{ //宣告函數
        require(StdtoData[nstdid].id != 0, "StudentID not Found");
        StdtoData[nstdid] = Data(StdtoData[nstdid].id, nstdid, nphone, nmail, naddr);
    }

    // delet data
    function deleteData(string memory nstdid) public onlyOwner{ //宣告函數
        require(StdtoData[nstdid].id != 0, "StudentID not Found");
        delete StdtoData[nstdid];
        delete IdtoStdid[StdtoData[nstdid].id];
        delete AddrtoData[StdtoData[nstdid].addr];
    }
}