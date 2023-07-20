function[list,default]=getFILBoardList


    if emlhdlcoder.hdlverifier.isHDLVerifierAvailable
        list=eda.internal.boardmanager.BoardManager.getInstance.getFILBoardNamesByVendor('all');
        list=[message('hdlcoder:hdlverifier:ChooseBoard').getString,...
        list,...
        message('hdlcoder:hdlverifier:CreateBoard').getString,...
        message('hdlcoder:hdlverifier:GetBoard').getString];
    else
        list={message('hdlcoder:hdlverifier:NoLicense').getString};
    end

    default=list{1};


