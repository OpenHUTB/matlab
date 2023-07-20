function gUnify(this)






    oldPropSet=PersistentHDLPropSet;
    oldEntityList=hdlgetparameter('entitynamelist');
    try
        hprop=hdlcoderprops.HDLProps;
        hprop.updateINI;
        PersistentHDLPropSet(hprop);
        oldCodeGen=hdlcodegenmode;
        hdlcodegenmode('filtercoder');
        hdlsetparameter('entitynamelist',{});

        unifyBlackBoxes(this);

        unifyTree(this);

    catch ME

        PersistentHDLPropSet(oldPropSet);
        hdlcodegenmode(oldCodeGen);
        if~isempty(oldEntityList)
            hdlsetparameter('entitynamelist',oldEntityList);
        end
        rethrow(ME);
    end

    PersistentHDLPropSet(oldPropSet);
    hdlcodegenmode(oldCodeGen);
    if~isempty(oldEntityList)
        hdlsetparameter('entitynamelist',oldEntityList);
    end


end




function unifyTree(this)


    uNamedObj=this.findComponent('UniqueName','');
    if isempty(uNamedObj)
        return;
    else
        sameNameObj=this.findComponent('Class',class(uNamedObj{1}));
        instName=sameNameObj{1}.InstName;
        if isempty(instName)
            instName=sameNameObj{1}.Name;
        end
        if isempty(sameNameObj{1}.UniqueName)
            UniqueName=hdluniqueentityname(instName);
            sameNameObj{1}.UniqueName=UniqueName;
        else
            UniqueName=sameNameObj{1}.UniqueName;
        end

        hdladdtoentitylist('',UniqueName,'','');

        codeGenTag=false;
        if sameNameObj{1}.flatten==0
            sameNameObj{1}.addprop('enableCodeGen');
            codeGenTag=true;
        end

        for loop=2:length(sameNameObj)
            currentObj=sameNameObj{loop};
            if isempty(currentObj.UniqueName)
                currentObj.UniqueName=UniqueName;
            end
            if currentObj.flatten==0&&~codeGenTag
                currentObj.addprop('enableCodeGen');
                codeGenTag=true;
            end
        end
        unifyTree(this);
    end
end


function unifyBlackBoxes(this)





    allBlackBoxes=this.findComponent('Class','eda.internal.component.BlackBox');
    for i=1:length(allBlackBoxes)
        BlackBox_I=allBlackBoxes{i};
        Name_I=BlackBox_I.Name;
        if isempty(BlackBox_I.UniqueName)
            if~isempty(allBlackBoxes{i}.findprop('wrapperFileNeeded'));
                allBlackBoxes{i}.addprop('enableCodeGen');
            end

            BlackBox_I.UniqueName=Name_I;
            for j=i+1:length(allBlackBoxes)
                BlackBox_J=allBlackBoxes{j};
                if strcmp(BlackBox_J.Name,Name_I)

                    BlackBox_J.UniqueName=Name_I;
                    if~isa(BlackBox_J,class(BlackBox_I))
                        warning(message('EDALink:Node:gUnify:BlackBoxCheck'));
                    end
                end
            end
        end



        [notUsed,entityName,~]=cellfun(@(x)fileparts(x),BlackBox_I.HDLFiles,'uniformOutput',false);%#ok<ASGLU>
        for loop=1:length(entityName)
            if~hdlentitynameexists(entityName{loop})
                hdladdtoentitylist('',entityName{loop},'','');
            end
        end
    end
end

