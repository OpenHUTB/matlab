function simrfV2_filt_s2box_setup(blk,Rsrc,Rload,ratFcns)









    OldElems=find_system(blk,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'FindAll','on',...
    'RegExp','on','Classname',...
    'inductor\w*|capacitor\w*|resistor\w*|f2port_rf\w*');
    if~isempty(OldElems)
        OldLines=find_system(blk,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'FindAll','on',...
        'Type','Line');
        delete_line(OldLines)
        delete(OldElems)


        libMod='simrfV2_lib';
        load_system(libMod);
        SrcBlk='S2PORT_RF';
        add_block([libMod,'/Sparameters/',SrcBlk],[blk,'/S2PORT_RF'],...
        'Position',[180,167,245,223])



        hasUnderMaskGnd=~isempty(find_system(blk,...
        'LookUnderMasks','all','FollowLinks','on',...
        'SearchDepth',1,'Parent',blk,'Name','Gnd1'));

        if hasUnderMaskGnd
            portNames={'1+','2+','Gnd1','Gnd2'};
            portSideDst={'RConn','RConn','LConn','LConn'};
        else
            portNames={'1+','2+','1-','2-'};
            portSideDst={'RConn','RConn','RConn','RConn'};
        end
        portIdx=[1,1,2,2];
        portSideSrc={'LConn','RConn','LConn','RConn'};
        for p_idx=1:4
            simrfV2connports(struct(...
            'SrcBlk',SrcBlk,...
            'SrcBlkPortStr',portSideSrc{p_idx},...
            'SrcBlkPortIdx',portIdx(p_idx),...
            'DstBlk',portNames{p_idx},...
            'DstBlkPortStr',portSideDst{p_idx},...
            'DstBlkPortIdx',1),blk);
        end
    end



    ACellNames={'P11','P21','P12','P22'};
    CCellNames={'R11','R21','R12','R22'};
    D=cell(4,1);
    Poles=D;
    Residues=D;




    ratFuns=ratFcns.DesignData;
    [Residues{1},Poles{1},D{1}]=simrfV2_filt_polezerores(...
    ratFuns.Numerator11,ratFuns.Denominator);
    [Residues{2},Poles{2},D{2}]=simrfV2_filt_polezerores(...
    ratFuns.Numerator21,ratFuns.Denominator);
    D{3}=D{2};
    Poles{3}=Poles{2};
    Residues{3}=Residues{2};
    [Residues{4},Poles{4},D{4}]=simrfV2_filt_polezerores(...
    ratFuns.Numerator22,ratFuns.Denominator);
    idxPolesNotEmpty=~cellfun(@isempty,D);
    D(~idxPolesNotEmpty)={0};

    x=cellfun(@horzcat,Poles,Residues,'UniformOutput',false);
    y=cellfun(@process_poles_residues,x,'UniformOutput',false);
    tempstr=cellfun(@(z)simrfV2vector2str(z(1,:)),y,...
    'UniformOutput',false);
    A=[ACellNames;reshape(tempstr,1,[])];
    tempstr=cellfun(@(z)simrfV2vector2str(z(2,:)),y,...
    'UniformOutput',false);
    C=[CCellNames;reshape(tempstr,1,[])];
    D=['D';{simrfV2vector2str(cell2mat(reshape(D,1,[])))}];
    Z0={'Z0';simrfV2vector2str([Rsrc,Rload])};
    sboxparam=[A(:);C(:);D(:);Z0(:);'FITOPT';'2']';
    set_param([blk,'/S2PORT_RF'],sboxparam{:})

    function y=process_poles_residues(xin)




        x=xin;
        tempy=[real(x(:,1)),imag(x(:,1)),real(x(:,2)),imag(x(:,2))];

        y=[reshape(tempy(:,1:2).',1,[]);reshape(tempy(:,3:4).',1,[])];

