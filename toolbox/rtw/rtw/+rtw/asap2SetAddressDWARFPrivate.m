function mHash=asap2SetAddressDWARFPrivate(ASAP2File,DWARFFile,addrPrefix,addrSuffix)




















    if nargin~=4
        DAStudio.error('RTW:asap2:invalidInputParam',mfilename)
    end


    if~exist(ASAP2File,'file')
        DAStudio.error('RTW:asap2:UnableFindFile',ASAP2File);
    end
    if~exist(DWARFFile,'file')
        DAStudio.error('RTW:asap2:UnableFindFile',DWARFFile);
    end


    varList='';
    varNameList=struct;
    dieHash=containers.Map;
    sList=struct;
    tList=struct;
    tRefList=struct;
    useAddrMapFlag=false;





    fid=fopen(DWARFFile);


    tline=[fgets(fid),fgets(fid)];


    addrMap=containers.Map;
    if contains(tline,'.symtab')





        tline=fgets(fid);
        while(~contains(tline,'debug_info section:')&&ischar(tline))
            if contains(tline,'OBJECT')&&...
                contains(tline,'GLOBAL')





                colIdx=strfind(tline,':');
                spcIdx=strfind(tline,' ');
                grIdx=find(spcIdx>colIdx);
                varName=deblank(tline(spcIdx(end)+1:end));
                varAddr=tline(spcIdx(grIdx(1))+1:spcIdx(grIdx(2))-1);
                addrMap(varName)=dec2hex(hex2dec(varAddr));
            end
            tline=fgets(fid);
        end

        useAddrMapFlag=true;
    end

    while ischar(tline)





        if contains(tline,'><')
            if contains(tline,'DW_TAG_variable')










                dieStr=getDieStr();
                if isExternVar(dieStr)





                    vName=getName(dieStr);
                    tmpName=['a',vName];
                    if~isfield(varNameList,tmpName)
                        varNameList.(tmpName)='';
                        vAddr=getAddr(dieStr,vName,addrMap,useAddrMapFlag);
                        if~isempty(vAddr)
                            idx=size(varList,2)+1;
                            varList(idx).name=vName;
                            varList(idx).type=getType(dieStr);
                            varList(idx).addr=vAddr;
                        end
                    end
                end

            elseif contains(tline,'DW_TAG_typedef')













                dieNo=getDieNo(tline);
                dieStr=getDieStr();

                if~contains(dieStr,'Void')
                    type=getType(dieStr);





                    tRefList.(['a_',type])=dieNo;


                    tName=['a_',getName(dieStr)];
                    if isfield(tList,tName)


                        type=tList.(tName);
                    else



                        tList.(tName)=type;
                    end

                    dieHash(dieNo)=type;
                end

            elseif contains(tline,'DW_TAG_const_type')||...
                contains(tline,'DW_TAG_volatile_type')















                dieNo=getDieNo(tline);
                dieStr=getDieStr();
                if~isempty(dieStr)


                    dieHash(dieNo)=getType(dieStr);
                end

            elseif contains(tline,'DW_TAG_structure_type')











                lCtr=0;
                mInfo=[];
                lineSkipNo=0;
                stName='';

                sLvl=getHierLvl(tline);
                dieNo=getDieNo(tline);
                [dieStr,lCtr]=getStructDieStr(1,lCtr);




                if contains(dieStr,'DW_AT_name')

                    tmpName=getName(dieStr);
                    if~isempty(tmpName)&&isvarname(tmpName)
                        stName=['a_',tmpName];
                        if isfield(sList,stName)

                            mInfo=sList.(stName).type;
                            lineSkipNo=sList.(stName).numLines-lCtr;
                        else

                            sList.(stName).type=dieNo;
                        end
                    end
                end




                if isempty(stName)

                    tmpDieNo=['a_',dieNo];
                    if isfield(tRefList,tmpDieNo)

                        dieNoRef=dieHash(tRefList.(tmpDieNo));
                        stName=['a_',dieNoRef];
                        if~strcmp(dieNoRef,dieNo)

                            mInfo=dieNoRef;
                            lineSkipNo=sList.(stName).numLines-lCtr;
                        end
                    else
                        stName=['a_',dieNo];
                    end
                end

                if isempty(mInfo)












                    sInfo=cell(10,1);
                    sInfo{sLvl}{1}=dieNo;
                    sInfo{sLvl}{2}=[];
                    rootSLvl=sLvl;

                    while(1)

                        cLvl=getHierLvl(tline);
                        if(cLvl-1)==sLvl

                            if contains(tline,'DW_TAG_member')


                                [dieStr,lCtr]=getStructDieStr(1,lCtr);
                                idx=size(sInfo{sLvl}{2},2)+1;
                                memName=getName(dieStr);


                                if~isempty(memName)
                                    sInfo{sLvl}{2}(idx).name=memName;
                                    sInfo{sLvl}{2}(idx).type=getType(dieStr);
                                    sInfo{sLvl}{2}(idx).offset=getOffset(dieStr);
                                end

                            else
                                if contains(tline,'DW_TAG_structure_type')


                                    sLvl=getHierLvl(tline);
                                    sInfo{sLvl}{1}=getDieNo(tline);
                                    sInfo{sLvl}{2}='';
                                end

                                [~,lCtr]=getStructDieStr(0,lCtr);

                            end
                        elseif cLvl>sLvl

                            [~,lCtr]=getStructDieStr(0,lCtr);

                        elseif cLvl<=sLvl




                            if cLvl==-1



                                cLvl=1;
                            end

                            for i=cLvl:sLvl
                                if~isempty(sInfo{i})
                                    dieHash(sInfo{i}{1})=sInfo{i}{2};
                                    sInfo{i}=[];
                                end
                            end
                            sLvl=cLvl-1;

                            if rootSLvl>=cLvl


                                if~isempty(stName)
                                    sList.(stName).numLines=lCtr;
                                end
                                break;
                            end

                        end
                    end
                else



                    for i=1:lineSkipNo
                        tline=fgets(fid);
                    end

                    dieHash(dieNo)=mInfo;
                end
            else
                tline=fgets(fid);
            end
        else
            tline=fgets(fid);
        end
    end
    fclose(fid);

    if~isempty(dieHash)&&~isempty(varList)

        mHash=expandVarAddr(varList,dieHash);
    elseif~isempty(addrMap)

        mHash=addrMap;
    end




    ASAP2FileString=fileread(ASAP2File);






    missingSymbolList={};
    invalidAddressList={};
    repfun=@(name)loc_getSymbolValForName(name);%#ok<NASGU>
    newASAP2FileString=regexprep(ASAP2FileString,...
    [addrPrefix,'(\S+)',addrSuffix],'0x${repfun($1)}');


    if~isempty(invalidAddressList)
        DAStudio.error('RTW:asap2:SymbolAddressExceedsLimit',strjoin(invalidAddressList,', '));
    end


    if~isempty(missingSymbolList)
        MSLDiagnostic('RTW:asap2:NoSymbolInTable',strjoin(missingSymbolList,', '),'DWARF',DWARFFile).reportAsWarning;
    end


    fid=fopen(ASAP2File,'w');
    fprintf(fid,'%s',newASAP2FileString);
    fclose(fid);





    function mHash=expandVarAddr(varList,dieHash)



        sIdx=1;
        eIdx=size(varList,2);
        mHash=containers.Map;


        while(1)
            for j=sIdx:eIdx
                ref=varList(j).type;
                name=varList(j).name;
                addr=varList(j).addr;


                mHash(name)=upper(addr);


                while(1)
                    if isstruct(ref)

                        name=varList(j).name;
                        addr=hex2dec(addr);


                        for k=1:size(ref,2)
                            vIdx=size(varList,2)+1;
                            varList(vIdx).name=[name,'.',ref(k).name];
                            varList(vIdx).type=ref(k).type;
                            varList(vIdx).addr=dec2hex(addr+str2double(ref(k).offset));
                        end


                        break;

                    else

                        if dieHash.isKey(ref)

                            ref=dieHash(ref);
                        else

                            break
                        end

                    end
                end
            end


            eIdxNew=size(varList,2);
            if eIdx==eIdxNew

                break
            else

                sIdx=eIdx+1;
                eIdx=eIdxNew;
            end
        end

    end

    function outDieStr=getDieStr()










        outDieStr='';
        while(1)
            tline=fgets(fid);
            if contains(tline,'><')||...
                ~contains(tline,'<')||...
                ~ischar(tline)
                break;
            end
            outDieStr=[outDieStr,tline];%#ok<AGROW>
        end
    end

    function[outDieStr,outCtr]=getStructDieStr(getDieStrFlag,inCtr)




        outDieStr='';
        outCtr=inCtr;
        while(1)
            tline=fgets(fid);
            outCtr=outCtr+1;
            if contains(tline,'><')||...
                ~contains(tline,'<')||...
                ~ischar(tline)
                break;
            end
            if getDieStrFlag==1
                outDieStr=[outDieStr,tline];%#ok<AGROW>
            end
        end
    end

    function outDieNo=getDieNo(dieStr)





        sIdx=strfind(dieStr,'<');
        eIdx=strfind(dieStr,'>');
        outDieNo=dieStr(sIdx(2)+1:eIdx(2)-1);
    end

    function outDtRef=getType(dieStr)







        tIdx=strfind(dieStr,'DW_AT_type');
        if isempty(tIdx)


            mIdx=strfind(dieStr,'DW_AT_name');
            aIdx=strfind(dieStr,'<');
            bIdx=strfind(dieStr,'>');
            sIdx=find(aIdx<mIdx);
            eIdx=find(bIdx<mIdx);
            outDtRef=dieStr(aIdx(sIdx(1))+1:bIdx(eIdx(1))-1);
        else
            aIdx=strfind(dieStr,'<');
            bIdx=strfind(dieStr,'>');
            sIdx=find(aIdx>tIdx);
            eIdx=find(bIdx>tIdx);
            outDtRef=dieStr(aIdx(sIdx(1))+1:bIdx(eIdx(1))-1);
            outDtRef=strrep(outDtRef,'0x','');
            outDtRef=strrep(outDtRef,'#','');
        end
    end

    function outAddr=getAddr(dieStr,vName,addrMap,useAddrMapFlag)







        outAddr='';
        if useAddrMapFlag
            if addrMap.isKey(vName)
                outAddr=addrMap(vName);
            end
        else
            tIdx=strfind(dieStr,'DW_OP_addr');
            if~isempty(tIdx)
                tIdx=tIdx+12;
                bIdx=strfind(dieStr,')');
                fIdx=find(bIdx>tIdx);
                outAddr=dieStr(tIdx:bIdx(fIdx(1))-1);
            end
        end
    end

    function outLvl=getHierLvl(dieStr)






        sIdx=strfind(dieStr,'<');
        if isempty(sIdx)


            outLvl=-1;
        else
            eIdx=strfind(dieStr,'>');
            outLvl=sscanf(dieStr(sIdx(1)+1:eIdx(1)-1),'%f',1);
        end
    end

    function outOffset=getOffset(dieStr)










        mIdx=strfind(dieStr,'member_location');
        memberStr=dieStr(mIdx:end);
        startIdx=strfind(memberStr,':');
        endIdx=strfind(memberStr,newline);
        offsetStr=memberStr(startIdx+1:endIdx);
        cIdx=strfind(offsetStr,'DW_OP_plus_uconst');
        dwOpConstString=cell2mat(regexp(offsetStr,'DW_OP_const([1 2 4 8])u','match'));
        tidx='';
        if~isempty(dwOpConstString)
            tidx=strfind(offsetStr,dwOpConstString);
        end
        if~isempty(cIdx)

            eIdx=strfind(offsetStr,')');
            outOffset=offsetStr(cIdx+19:eIdx-1);
        elseif~isempty(tidx)

            eIdx=strfind(offsetStr,')');
            outOffset=offsetStr(tidx+15:eIdx-1);
        else

            outOffset=offsetStr;
        end
    end

    function outName=getName(dieStr)







        tIdx=strfind(dieStr,'DW_AT_name');
        if isempty(tIdx)


            outName='';
        else
            aIdx=strfind(dieStr,'<');
            bIdx=strfind(dieStr,':');
            cIdx=find(tIdx<aIdx,1);
            if isempty(cIdx)
                outName=dieStr(bIdx(end)+2:end);
            else
                eIdx=aIdx(cIdx)-1;
                sIdx=find(bIdx<eIdx);
                outName=dieStr(bIdx(sIdx(end))+2:eIdx);
            end
            outName=deblank(outName);
        end
    end

    function status=isExternVar(dieStr)







        status=false;
        if contains(dieStr,'DW_AT_name')&&...
            (contains(dieStr,'DW_OP_addr')||...
            contains(dieStr,'location list'))
            status=true;
        end

    end

    function hexaddr=loc_getSymbolValForName(name)
        try

            hexaddr=mHash(name);
            if hex2dec(hexaddr)>0xFFFFFFFF
                invalidAddressList{end+1}=name;
            end
        catch

            hexaddr=['0000 /* @ECU_Address@',name,'@ */'];
            missingSymbolList{end+1}=name;
        end
    end

end



