function[uchnlidx,ychnlidx]=getStateBlockChannelsOnPath(mg,stateblkh)



    import linearize.advisor.graph.*
    handles=[mg.Nodes.JacobianBlockHandle]';
    types=[mg.Nodes.Type]';
    uchannels=(handles==stateblkh)&(types==NodeTypeEnum.INCHANNEL);
    ychannels=(handles==stateblkh)&(types==NodeTypeEnum.OUTCHANNEL);
    uchnlidx=[mg.Nodes(uchannels).Channel]';
    ychnlidx=[mg.Nodes(ychannels).Channel]';


    uchnlidx(mod(uchnlidx-1,4)>0)=[];
    uchnlidx=(uchnlidx-1)/4+1;








