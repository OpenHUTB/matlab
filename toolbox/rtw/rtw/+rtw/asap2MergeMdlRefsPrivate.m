function[status,info]=asap2MergeMdlRefsPrivate(TopModelName,OutFileName)






















    if nargin~=2
        DAStudio.error('RTW:asap2:invalidInputParam',mfilename)
    end


    if~ischar(TopModelName)
        DAStudio.error('RTW:utility:invalidArgType','char array');
    end

    if(exist(TopModelName,'file')~=4)
        DAStudio.error('RTW:utility:invalidModel',TopModelName);
    end


    pathList=RTW.getBuildDir(TopModelName);
    topDir=pathList.BuildDirectory;
    prjDir=fullfile(pathList.CodeGenFolder,pathList.ModelRefRelativeRootTgtDir);

    asap2File=fullfile(topDir,[TopModelName,'.a2l']);
    if~exist(asap2File,'file')
        DAStudio.error('RTW:asap2:TopModelASAP2Off',TopModelName)
    end


    expList=getExpList(topDir,prjDir,TopModelName);


    asap2Str=fileread(asap2File);
    asap2Objs=initAsap2Objs(asap2Str,TopModelName,expList(1).cDepList.vars);


    for m=2:size(expList,2)

        asap2File=fullfile(expList(m).path,[expList(m).mdlName,'.a2l']);
        asap2Str=fileread(asap2File);


        asap2Str=regexprep(asap2Str,'localDW->',[expList(m).structStr,'.rtdw.']);
        asap2Str=regexprep(asap2Str,'localB->',[expList(m).structStr,'.rtb.']);


        asap2Objs=getAsap2Objs(asap2Objs,asap2Str,expList(m).mdlName,...
        expList(m).cDepList.vars);
    end


    asap2Objs=linkGroups(asap2Objs,expList);


    writeASAP2File(asap2Objs,OutFileName);


    if isempty(asap2Objs.par.info)
        status=false;
        info='';
    else
        status=true;
        info=asap2Objs.par.info;
    end






    function outObjs=linkGroups(inObjs,expList)




        groupList=containers.Map;






        names=regexp(inObjs.group{1},...
        '/begin\s+GROUP\s+(?:/\*.*?\*\/)?\s*(\S+)','tokens');

        for q=1:size(names,2)
            groupList(names{q}{1})='';
        end


        for n=2:size(expList,2)

            pGroupStr=inObjs.group{expList(n).parentIdx};
            cGroupStr=inObjs.group{n};


            cName=expList(n).mdlName;
            names=regexp(cGroupStr,...
            '/begin\s+GROUP\s+(?:/\*.*?\*\/)?\s*(\S+)','tokens');



            if isempty(expList(n).dWork)
                dWorkStr='';
            else
                dWorkStr=['_',expList(n).dWork];
            end


            pMdlRefName=['mr_grp2link_',cName,dWorkStr];
            if~isempty(names)
                [cMdlRefName,groupList]=checkGroupName(cName,groupList);

                if~strcmp(cName,cMdlRefName)
                    newStr=sprintf([' ',cMdlRefName,newLineChar]);
                    cGroupStr=regexprep(cGroupStr,...
                    [' ',cName,newLineChar,'{1}'],newStr);
                end


                if~isempty(names)
                    for l=2:size(names,2)
                        [newName,groupList]=checkGroupName(names{l}{1},groupList);
                        if~strcmp(newName,names{l}{1})
                            newStr=sprintf([' ',newName,newLineChar]);
                            cGroupStr=regexprep(cGroupStr,...
                            [' ',names{l}{1},newLineChar,'{1}'],newStr);
                        end
                    end
                end


                cGroupStr=regexprep(cGroupStr,'(?-s)\s+.+ROOT','');
            else
                pMdlRefName=['(?-s)\s+.+',pMdlRefName,'[\W+]'];
                cMdlRefName=newLineChar;
            end
            pGroupStr=regexprep(pGroupStr,pMdlRefName,cMdlRefName);


            inObjs.group{expList(n).parentIdx}=pGroupStr;
            inObjs.group{n}=cGroupStr;
        end
        outObjs=inObjs;
    end

    function[outName,outList]=checkGroupName(name,inList)




        if inList.isKey(name)

            sufNo=1;
            while(1)
                tmpNameS=[name,num2str(sufNo)];
                if inList.isKey(tmpNameS)

                    sufNo=sufNo+1;
                else
                    inList(tmpNameS)='';
                    outName=tmpNameS;
                    break
                end
            end
        else

            inList(name)='';
            outName=name;
        end
        outList=inList;
    end

    function outList=getExpList(topDir,prjDir,mdlName)




        outList(1).mdlName=mdlName;
        outList(1).path=topDir;
        outList(1).structStr='';
        outList(1).dWork='';
        outList(1).parentIdx=0;
        outList(1).cDepList=struct;


        sIdx=1;
        eIdx=1;

        while(1)

            for k=sIdx:eIdx
                outList=updateExpList(outList,prjDir,k);
            end


            newEIdx=size(outList,2);
            if newEIdx==eIdx

                break
            else

                sIdx=eIdx+1;
                eIdx=size(outList,2);
            end
        end

    end

    function outList=updateExpList(inList,pDir,k)





        bInfoFile=fullfile(inList(k).path,'buildInfo.mat');
        bInfo=load(bInfoFile);







        mdlList=bInfo.buildOpts.DirectModelReferenceInstancesAsap2;


        dWorkDepFileName=...
        fullfile(inList(k).path,[inList(k).mdlName,'_dwork_dependency.list']);
        dWorkInfo=getDworkInfo(dWorkDepFileName);


        if isempty(inList(k).structStr)
            pGroupStructStr=dWorkInfo.dWork;
            inList(k).structStr=dWorkInfo.dWork;
        else
            pGroupStructStr=inList(k).structStr;
        end


        if(k>1)

            pIdx=inList(k).parentIdx;
            cDepList=getCanonicalDependList(inList(k).path,...
            inList(k).mdlName,inList(k).dWork,inList(pIdx).cDepList);
        else

            cDepList=getCanonicalDependList(inList(k).path,...
            inList(k).mdlName,'','');
        end
        inList(k).cDepList=cDepList;


        if~isempty(mdlList)
            for i=1:length(mdlList)

                name=mdlList{i};
                mrDWork='';
                structStr='';

                for j=1:size(dWorkInfo.mdlRefDWork,1)
                    if strcmp(name,dWorkInfo.mdlRefDWork{j,1})


                        mrDWork=dWorkInfo.mdlRefDWork{j,2};
                        dWorkInfo.mdlRefDWork(j,:)='';
                        if k~=1&&dWorkInfo.isMdlRefDW==1
                            structStr=[pGroupStructStr,'.rtdw.',mrDWork];
                        else
                            structStr=[pGroupStructStr,'.',mrDWork];
                        end
                        break
                    end
                end

                refDWorkDepFileName=...
                fullfile([pDir,filesep,name],[name,'_dwork_dependency.list']);
                if exist(refDWorkDepFileName,'file')>0
                    idx=size(inList,2)+1;
                    inList(idx).mdlName=name;
                    inList(idx).path=[pDir,filesep,name];
                    inList(idx).structStr=structStr;
                    inList(idx).dWork=mrDWork;
                    inList(idx).parentIdx=k;
                    inList(idx).cDepList=struct;
                else

                    MSLDiagnostic('RTW:asap2:RefModelASAP2Off',name).reportAsWarning;
                end
            end
        end

        outList=inList;
    end

    function list=getCanonicalDependList(path,mdlName,dWork,cList)









        list.vars=struct;


        list.depend=struct;

        if isempty(dWork)
            dWork='SELF_ARG';
        end

        if isempty(cList)
            cList.depend=struct;
        end


        fStr=fileread([path,filesep,mdlName,'_canonical_dependency.list']);
        tkns=regexp(fStr,'(\S+)\->(\S+)\@(\S+)\@(\S+)\s+','tokens');


        for i=1:size(tkns,2)

            if isfield(cList.depend,mdlName)
                skip=false;
                splitStr=regexp(dWork,'\.','split');
                currStruct=cList.depend.(mdlName);
                for j=1:length(splitStr)
                    currField=splitStr{j};
                    if~isfield(currStruct,currField)
                        skip=true;
                        break;
                    else
                        currStruct=currStruct.(currField);
                    end
                end
                if~skip&&isfield(currStruct,tkns{i}{1})
                    pName=currStruct.(tkns{i}{1});
                else
                    continue
                end
            else
                if~strcmp((tkns{i}{3}),'SELF_ARG')
                    pName=tkns{i}{1};
                else

                    continue
                end
            end


            if strcmp((tkns{i}{3}),'SELF_ARG')
                list.vars.(tkns{i}{1})=pName;
            end


            eval(['list.depend.',tkns{i}{3},'.',(tkns{i}{4}),'.',(tkns{i}{2}),'=''',pName,''';']);
        end

    end

    function dInfo=getDworkInfo(DWorkDependFile)








        dWork='';
        mdlRefDWork={};

        listStr=fileread(DWorkDependFile);
        nlIdx=regexp(listStr,'\n');

        if~isempty(nlIdx)
            dWork=deblank(listStr(1:nlIdx(1)));
            for i=2:size(nlIdx,2)
                str=strtrim(listStr(nlIdx(i-1):nlIdx(i)));
                tIdx=strfind(str,'@');
                mdlRefDWork{i-1,1}=str(tIdx+1:end);
                mdlRefDWork{i-1,2}=str(1:tIdx-1);
            end
        end
        dInfo=regexp(dWork,'\D*(?<isMdlRefDW>\d+)\s+(?<dWork>\S+)','names');
        dInfo.isMdlRefDW=str2double(dInfo.isMdlRefDW);
        dInfo.mdlRefDWork=mdlRefDWork;
    end

    function objs=initAsap2Objs(asap2Str,mdlName,canDepVars)






        objs.header{1}=getHeader(asap2Str);
        objs.par.entry={};

        objs.par.cNames=struct;
        objs.par.aNames=struct;
        objs.par.info='';
        objs.sig={};
        objs.record.entry={};
        objs.record.names=struct;
        objs.compumethod.entry={};
        objs.compumethod.names=struct;
        objs.compuvtab.entry={};
        objs.compuvtab.names=struct;
        objs.group={};
        objs.footer{1}=getFooter(asap2Str);


        objs=getAsap2Objs(objs,asap2Str,mdlName,canDepVars);
    end

    function outObjs=getAsap2Objs(inObjs,asap2Str,mdlName,canDepVars)




        inObjs.sig=getObjs(inObjs.sig,asap2Str,'MEASUREMENT',4);
        inObjs.group=getObjs(inObjs.group,asap2Str,'GROUP',4);
        inObjs.compumethod=getObjs(inObjs.compumethod,asap2Str,'COMPU_METHOD',4);
        inObjs.compuvtab=getObjs(inObjs.compuvtab,asap2Str,'COMPU_VTAB',4);
        inObjs.record=getRecObjs(inObjs.record,asap2Str,mdlName,4);
        [inObjs.par,inObjs.group{end}]=...
        getParObjs(inObjs.par,asap2Str,'CHARACTERISTIC',4,...
        inObjs.group{end},inObjs.record,mdlName,canDepVars);
        [inObjs.par,inObjs.group{end}]=...
        getParObjs(inObjs.par,asap2Str,'AXIS_PTS',4,...
        inObjs.group{end},inObjs.record,mdlName,canDepVars);


        outObjs=inObjs;
    end

    function[outObjs,outGroup]=...
        getParObjs(inObjs,asap2Str,keyword,sOffset,inGroup,recObjs,mdlName,canDepVars)





        sIdxs=regexp(asap2Str,['begin\s+',keyword]);
        eIdxs=regexp(asap2Str,['end\s+',keyword],'end');


        if~isempty(sIdxs)&&~isempty(eIdxs)

            for ip=1:size(sIdxs,2)
                removeFromGroup=false;


                str=asap2Str(sIdxs(ip)-sOffset-1:eIdxs(ip)+1);
                name=cell2mat(regexp(str,'Name\s+*/\s+(\S+)','tokens','once'));


                patStr='/\*\s+MODEL\s+ARGUMENT\s+(VALUE\s+)?*/';
                if~isempty(regexp(str,patStr,'once'))
                    validateNotEmpty(name);
                    if isfield(canDepVars,name)
                        str=regexprep(str,['(\/\*\s+Name\s+\*\/\s+)',name],...
                        ['$1',canDepVars.(name)]);
                        str=regexprep(str,['(@ECU_Address@)',name],...
                        ['$1',canDepVars.(name)]);
                        vList=fieldnames(canDepVars);
                        for jp=1:size(vList,1)
                            if~isempty(strfind(str,vList{jp}))
                                str=regexprep(str,['(AXIS_PTS_REF\s+)',vList{jp}],...
                                ['$1',canDepVars.(vList{jp})]);
                            end
                        end
                        name=canDepVars.(name);
                    else

                        continue;
                    end
                end

                switch keyword

                case 'CHARACTERISTIC'







                    patStr='\s+Type\s+*/\s+(\w+)';
                    type=cell2mat(regexp(str,patStr,'tokens','once'));
                    validateNotEmpty(type);






                    if strcmp(type,'CURVE')||strcmp(type,'MAP')
                        patStr='Axis\s+Type\s+*/\s+(\w+)';
                        tmpType=regexp(str,patStr,'tokens');
                        type='';
                        for i=1:size(tmpType,2)
                            type=[type,tmpType{i}{1}];
                        end
                    end

                    isCapturedInChar=isMemberOfStruct(inObjs.cNames,name);
                    isCapturedInAxis=isMemberOfStruct(inObjs.aNames,name);

                    if~isCapturedInChar&&...
                        ~isCapturedInAxis

                        addToEntry=true;

                        if contains(type,'COM_AXIS')

                            axis=regexp(str,'AXIS_PTS_REF\s+(\S+)','tokens');
                            axisNo=size(axis,2);
                            for j=1:axisNo
                                aName=axis{j}{1};
                                if isMemberOfStruct(inObjs.cNames,aName)



                                    removeFromGroup=true;
                                    addToEntry=false;
                                    break
                                end
                            end
                        elseif contains(type,'STD_AXIS')

                            recName=cell2mat(regexp(str,...
                            'Record Layout\s+\S+\s+(\w+)','tokens','once'));
                            validateNotEmpty(recName);
                            if isfield(recObjs.names.(recName).skiplist,mdlName)


                                removeFromGroup=true;
                                addToEntry=false;

                                inObjs.info=updateInfo(inObjs.info,name,mdlName,...
                                ['Previously occurrence of RECORD_LAYOUT '...
                                ,recName,' has different layout!']);
                            end
                        end

                        if(addToEntry==true)

                            eval(['inObjs.cNames.',name,'= type;']);
                            idx=size(inObjs.entry,2)+1;
                            inObjs.entry{idx}=str;
                        end

                    elseif isCapturedInChar


                        currCType=eval(['inObjs.cNames.',name]);
                        if~strcmp(currCType,type)
                            inObjs.info=updateInfo(inObjs.info,name,mdlName,...
                            [type,' previously used as ',currCType]);
                            removeFromGroup=true;
                        end

                    elseif isCapturedInAxis


                        inObjs.info=updateInfo(inObjs.info,name,mdlName,...
                        'CHARACTERISTIC previously used as AXIS_PTS!');
                        removeFromGroup=true;
                    end

                case 'AXIS_PTS'

                    isCapturedInChar=isMemberOfStruct(inObjs.cNames,name);
                    isCapturedInAxis=isMemberOfStruct(inObjs.aNames,name);

                    if~isCapturedInChar&&...
                        ~isCapturedInAxis

                        eval(['inObjs.aNames.',name,'= '''';']);
                        idx=size(inObjs.entry,2)+1;
                        inObjs.entry{idx}=str;

                    elseif isCapturedInChar


                        inObjs.info=updateInfo(inObjs.info,name,mdlName,...
                        'AXIS_PTS previously used as CHARACTERISTIC!');
                        removeFromGroup=true;
                    end

                otherwise

                end

                if(removeFromGroup==true)

                    inGroup=regexprep(inGroup,['\s+',name,'[ \t]*(?=\s+)'],'');
                end

            end
        end
        outObjs=inObjs;
        outGroup=inGroup;


        function outInfo=updateInfo(inInfo,name,fileName,msg)
            InfoStr=['# Skipped object: ',name,' for ',fileName,'. ',msg];
            outInfo=[inInfo,sprintf('%s\n',InfoStr)];
        end

    end

    function outObjs=getRecObjs(inObjs,asap2Str,mdlName,sOffset)





        sIdx=regexp(asap2Str,'begin\s+RECORD_LAYOUT');
        eIdx=regexp(asap2Str,'end\s+RECORD_LAYOUT','end');

        for cI=1:size(sIdx,2)

            str=asap2Str(sIdx(cI)-sOffset-1:eIdx(cI));


            name=cell2mat(regexp(str,'/begin\s+\S+\s+(\w+)','tokens','once'));
            assert(~isempty(name));
            if~isfield(inObjs.names,name)

                idx=size(inObjs.entry,2)+1;
                inObjs.entry{idx}=str;
                inObjs.names.(name).idx=idx;
                inObjs.names.(name).skiplist=struct;
            else

                oldEntry=inObjs.entry{inObjs.names.(name).idx};
                if~strcmp(oldEntry,str)


                    if~isfield(inObjs.names.(name).skiplist,mdlName)
                        inObjs.names.(name).skiplist.(mdlName)='';
                    end
                end
            end
        end

        outObjs=inObjs;
    end

    function isAMember=isMemberOfStruct(aStruct,aMember)




        isAMember=true;
        splitStr=regexp(aMember,'\.','split');
        currStruct=aStruct;
        for j=1:length(splitStr)
            currField=splitStr{j};
            if~isfield(currStruct,currField)
                isAMember=false;
                break;
            else
                currStruct=currStruct.(currField);
            end
        end
    end

    function outObjs=getObjs(inObjs,asap2Str,keyword,sOffset)





        sIdx=regexp(asap2Str,['begin\s+',keyword]);
        eIdx=regexp(asap2Str,['end\s+',keyword],'end');

        switch keyword

        case{'COMPU_METHOD','COMPU_VTAB','RECORD_LAYOUT'}

            for cI=1:size(sIdx,2)

                str=asap2Str(sIdx(cI)-sOffset-1:eIdx(cI));


                switch keyword
                case 'RECORD_LAYOUT'

                    strPat='/begin\s+\S+\s+(\w+)';
                case 'COMPU_METHOD'

                    strPat='Name\s+of\s+CompuMethod\s+*/\s+(\S+)';
                case 'COMPU_VTAB'

                    strPat='Name\s+of\s+Table\s+*/\s+(\S+)';
                end
                name=cell2mat(regexp(str,strPat,'tokens','once'));
                validateNotEmpty(name);


                if~isfield(inObjs.names,name)
                    inObjs.names.(name)='';
                    idx=size(inObjs.entry,2)+1;
                    inObjs.entry{idx}=str;
                end

            end

        otherwise

            if~isempty(sIdx)&&~isempty(eIdx)
                str=asap2Str(sIdx-sOffset-1:eIdx(end)+1);
            else
                str='';
            end
            idx=size(inObjs,2)+1;
            inObjs{idx}=str;

        end

        outObjs=inObjs;
    end

    function writeASAP2File(inObj,outFile)




        outStrs={inObj.header,inObj.record.entry,inObj.par.entry,...
        inObj.sig,inObj.compumethod.entry,inObj.compuvtab.entry,inObj.group,inObj.footer};


        if~ispc
            nlc='\n\n';
        else

            nlc='\r\n\r\n';
        end


        fid=fopen(outFile,'wb');
        for ii=1:size(outStrs,2)
            oStrs=outStrs{ii};
            for j=1:size(oStrs,2)
                oStr=oStrs{j};
                if~isempty(oStr)
                    fprintf(fid,'%s',sprintf(['%s',nlc],deblank(oStrs{j})));
                end
            end
        end
        fclose(fid);
    end

    function outStr=getHeader(inStr)






        hIdxs=regexp(inStr,'/begin\s+RECORD_LAYOUT','ONCE');
        if isempty(hIdxs)
            disp('Header section information not found');
            outStr='';
        else
            outStr=inStr(1:hIdxs(end)-1);
        end
    end

    function outStr=getFooter(inStr)






        fIdxs=regexp(inStr,'\end\s+MODULE','ONCE');
        if isempty(fIdxs)
            disp('Footer section information not found');
            outStr='';
        else
            outStr=inStr(fIdxs-1:end);
        end
    end

    function outStr=newLineChar()
        if ispc
            outStr='\r';
        else
            outStr='\n';
        end
    end

    function validateNotEmpty(field)
        if isempty(field)
            DAStudio.error('RTW:asap2:ASAP2FileNotGeneratedFromSimulink',asap2File);
        end
    end
end



