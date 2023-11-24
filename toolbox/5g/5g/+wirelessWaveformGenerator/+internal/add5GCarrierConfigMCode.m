function varName=add5GCarrierConfigMCode(sw,cfgObj,mCodeConfig)

    if~iscell(mCodeConfig)
        mCodeConfig={mCodeConfig};
    end

    sectionHeader=string(mCodeConfig{1}.SectionHeader);
    for line=1:numel(sectionHeader)
        addcr(sw,sectionHeader{line});
    end

    numCfg=numel(cfgObj);
    for o=1:numCfg
        thisMCodeConfig=mCodeConfig{o};

        [firstLineEnd,anyLineEnd,lastLineEnd,sep]=getTerminators(thisMCodeConfig.CreationMethod);

        if iscell(cfgObj)
            thisCfgObj=cfgObj{o};
        else
            thisCfgObj=cfgObj;
        end


        if isprop(thisCfgObj,'CustomPropList')
            propList=thisCfgObj.CustomPropList;
        else
            propList=properties(thisCfgObj);
        end
        numProp=numel(propList);


        className=class(thisCfgObj);
        m=meta.class.fromName(className);



        if numCfg>1
            instanceHeader=getInstanceHeader(mCodeConfig,o);
            if~isempty(instanceHeader)
                addcr(sw,instanceHeader+" "+repmat(num2str(o),numCfg>1));
            end
        end


        varName=getVarName(thisCfgObj,mCodeConfig,o);
        varNameWithNum=string(varName)+repmat(num2str(o),numCfg>1);


        addcr(sw,varNameWithNum+" = "+className+firstLineEnd)



        isObjProp=false(1,numProp);
        for p=1:numProp
            thisPropVal=thisCfgObj.(propList{p});


            isObjProp(p)=isObjProperty(thisPropVal);
            idxMetaProp=strcmpi(propList{p},{m.PropertyList.Name});
            isPrivateProp=strcmpi(m.PropertyList(idxMetaProp).SetAccess,'private');
            if isObjProp(p)||isPrivateProp
                continue;
            end


            thisPropStr=prop2String(thisPropVal);


            if p>1
                if strcmpi(thisMCodeConfig.CreationMethod,"Constructor")
                    add(sw,anyLineEnd);
                end
                addcr(sw);
            end


            if strcmpi(thisMCodeConfig.CreationMethod,"Constructor")

                add(sw,"'"+propList{p}+"',"+thisPropStr);
            else

                add(sw,varNameWithNum+"."+propList{p}+sep+thisPropStr+anyLineEnd);
            end
        end
        addcr(sw,lastLineEnd);
        addcr(sw,"");


        objPropList=propList(isObjProp);
        for p=1:sum(isObjProp)
            thisPropCfgObj=thisCfgObj.(objPropList{p});
            thisPropMCodeConfig=thisMCodeConfig.(objPropList{p});
            thisPropMCodeConfig=addParentName(thisPropCfgObj,thisPropMCodeConfig,varNameWithNum);

            objName=wirelessWaveformGenerator.internal.add5GCarrierConfigMCode(sw,thisPropCfgObj,thisPropMCodeConfig);


            numObj=numel(thisPropCfgObj);
            if numObj>1
                objNames=char(join(string(objName)+(1:numObj),','));
            else
                objNames=objName;
            end

            leftBracket=repmat('{',iscell(thisPropCfgObj));
            rightBracket=repmat('}',iscell(thisPropCfgObj));


            addcr(sw,varNameWithNum+"."+objPropList{p}+" = "+leftBracket+objNames+rightBracket+";");
            addcr(sw,'');
        end
    end
    indentCode(sw,'matlab');
end

function out=isObjProperty(prop)
    if iscell(prop)
        out=isobject(prop{1});
    else
        out=isobject(prop);
    end
end

function propStr=prop2String(propVal)



    if iscell(propVal)
        propStr='{';
    else
        propVal={propVal};
        propStr='';
    end


    for n=1:length(propVal)
        sep=repmat(',',n>1);
        if isnumeric(propVal{n})||islogical(propVal{n})
            strValue=mat2str(propVal{n});




            d=diff(propVal{n});
            if(numel(propVal{n})>2)&&~isempty(d)
                if all(d==0)
                    if propVal{n}(1)==1
                        onesMultiplier=char;
                    else
                        onesMultiplier=[num2str(propVal{n}(1)),'*'];
                    end
                    strValue=[onesMultiplier,'ones(',mat2str(size(propVal{n})),')'];
                elseif numel(unique(d))==1
                    strValue=[num2str(propVal{n}(1)),':',repmat([num2str(d(1)),':'],1,d(1)~=1),num2str(propVal{n}(end))];
                end
            end


            propStr=[propStr,sep,strValue];%#ok<AGROW>
        elseif ischar(propVal{n})
            propStr=[propStr,sep,'''',propVal{n},''''];%#ok<AGROW>
        end
    end

    if propStr(1)=='{'
        propStr=[propStr,'}'];
    end

end

function instanceHeader=getInstanceHeader(mCodeConfig,index)

    if~isempty(mCodeConfig{index}.InstanceHeader)
        instanceHeader=mCodeConfig{index}.InstanceHeader;
    elseif~isempty(mCodeConfig{1}.InstanceHeader)
        instanceHeader=mCodeConfig{1}.InstanceHeader;
    else
        instanceHeader=[];
    end
end

function varName=getVarName(cfgObj,mCodeConfig,index)


    if~isempty(mCodeConfig{index}.VarName)
        varName=mCodeConfig{index}.VarName;
    elseif~isempty(mCodeConfig{1}.VarName)
        varName=mCodeConfig{1}.VarName;
    else
        varName=[];
    end

    if isempty(varName)
        varName=generateVarName(cfgObj);
    end
end


function varName=generateVarName(cfg)
    if iscell(cfg)
        cfg=cfg{1};
    end
    className=class(cfg);

    vname=lower(extractBetween(className,"nrWavegen","Config"));
    if isempty(vname)
        vname=lower(extractBetween(className,"nr","Config"));
    end
    varName=vname{1};
end

function mCodeConfig=addParentName(cfgObj,mCodeConfig,varName)

    if~iscell(mCodeConfig)
        mCodeConfig={mCodeConfig};
    end
    for o=1:length(mCodeConfig)
        thisMCodeConfig=mCodeConfig{o};


        prefix=string(repmat(char(varName),thisMCodeConfig.IncludeParentName));
        thisPropVarName=getVarName(cfgObj,mCodeConfig,o);



        mCodeConfig{o}.VarName=char(prefix+thisPropVarName);
    end
end

function[firstLineEnd,anyLineEnd,lastLineEnd,sep]=getTerminators(method)
    if strcmpi(method,"Constructor")
        firstLineEnd="( ... ";
        sep=",";
        anyLineEnd=", ...";
        lastLineEnd=");";
    else
        firstLineEnd=";";
        sep=" = ";
        anyLineEnd=firstLineEnd;
        lastLineEnd="";
    end
end