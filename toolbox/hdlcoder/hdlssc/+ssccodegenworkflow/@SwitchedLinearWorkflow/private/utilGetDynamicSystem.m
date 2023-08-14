function dynamicSystem=utilGetDynamicSystem(simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths)




    try
        solverParams=NetworkEngine.SolverParameters;
        localSolverChoice=get_param(solverPaths,'LocalSolverChoice');
        partitionMethod=get_param(solverPaths,'PartitionMethod');
        partitionNetwork=strcmp(localSolverChoice,'NE_PARTITIONING_ADVANCER');
        modechartSupported=matlab.internal.feature("SSC2HDLModechart");

        dynamicSystem=simscape.compileModel(simscapeSF,...
        'InputFilteringFcn',simscapeSFInputs,...
        'OutputFilteringFcn',simscapeSFOutputs,...
        'ResidualTolerance',solverParams.ResidualTolerance,...
        'PartitioningNetwork',partitionNetwork,...
        'PartitionMethod',partitionMethod,...
        'CheckSsc2Hdl',true,...
        'Ssc2Hdl',true,...
        'AllowLinearTluSSC2HDL',true,...
        'AllowIntDiscreteSSC2HDL',modechartSupported);

    catch me
        if strcmp(me.identifier,'physmod:simscape:compiler:core:ds:CannotGenerateMATLABFunction')


            throwAsCaller(me);
        elseif strcmp(me.identifier,'physmod:common:mf:system:xform:HDLNotCompatible')


            a=[];
            for j=1:length(me.cause)-1
                a1=[];
                if~isempty(me.cause{j}.cause)
                    l=length(me.cause{j}.cause);
                else
                    l=1;
                end

                strLink=[];

                for k=1:length(me.cause{j}.cause)
                    strLink=[strLink,string(me.cause{j}.cause{k}.message)];
                end
                strLink=unique(strLink);
                strFlag=ones(numel(strLink),1);
                for i=1:l

                    if~isempty(me.cause{j}.stack)||((~isempty(me.cause{j}.cause))&&(~isempty(me.cause{j}.cause{i}.stack)))

                        if~isempty(me.cause{j}.cause)
                            filepath=me.cause{j}.cause{i}.stack(1).file;
                        else
                            filepath=me.cause{j}.stack(1).file;
                        end


                        index=find(filepath==filesep,1,'last');


                        if isempty(index)
                            index=1;
                        end

                        filepathNew=strrep(filepath,'\','\\');
                        if~isempty(me.cause{j}.cause)
                            lineNum=me.cause{j}.cause{i}.stack(1).line;
                        else
                            lineNum=me.cause{j}.stack(1).line;
                        end
                        if~isempty(filepathNew)
                            msg=sprintf(['See file <a href = "matlab:open(',sprintf('''%s'')"',filepathNew),'>%s</a> at line %d.'],filepath(index+1:end),lineNum);
                            msg=strrep(msg,'\','\\');
                        else
                            msg='';
                        end
                    else

                        msg='';
                        filepath='';
                    end


                    if~any(strfind(filepath,'.sscp'))
                        if~isempty(me.cause{j}.cause)
                            a1=[a1,me.cause{j}.cause{i}.message,msg,'<br>'];
                        else
                            a=[a,me.cause{j}.message,'. ',msg];
                        end
                    else

                        if isempty(me.cause{j}.cause)


                        else

                            if numel(strLink)==1&&strFlag
                                a1=[a1,me.cause{j}.cause{i}.message,me.cause{j}.message,'<br>'];
                                strFlag=0;
                            else

                                ind=strcmp(me.cause{j}.cause{i}.message,strLink);
                                if strFlag(ind)
                                    strFlag(ind)=0;
                                    charMsg=char(strLink(ind));
                                    colonIdx=strfind(charMsg,':');
                                    a1=[a1,charMsg(1:colonIdx(end)-1),'<br>'];
                                end
                            end
                        end
                    end
                end


                if~isempty(a1)&&~(any(strfind(a1,me.cause{j}.message)))
                    a1=[me.cause{j}.message,'. ','<br>',a1];
                end
                if~isempty(a)
                    addBR='<br>';
                else
                    addBR='';
                end
                a=[a,addBR,a1];
            end



            b=[];
            b1=[];
            strLink1=[];

            for k=1:length(me.cause{end}.cause)
                strLink1=[strLink1,string(me.cause{end}.cause{k}.message)];
            end
            strLink1=unique(strLink1);
            strFlag1=ones(numel(strLink1),1);
            for h=1:length(strLink1)
                if any(strfind(a,strLink1(h)))
                    strFlag1(h)=0;
                end
            end
            if~isempty(me.cause{end}.cause)
                l=length(me.cause{end}.cause);
            else
                l=1;
            end
            for i=1:l

                if~isempty(me.cause{end}.stack)||((~isempty(me.cause{end}.cause))&&(~isempty(me.cause{end}.cause{i}.stack)))

                    if~isempty(me.cause{end}.cause)
                        filepath=me.cause{end}.cause{i}.stack(1).file;
                        checkBlockName=me.cause{end}.cause{i}.message;
                    else
                        filepath=me.cause{end}.stack(1).file;
                        stInd=strfind(me.cause{end}.message,'[');
                        endInd=strfind(me.cause{end}.message,']');
                        checkBlockName=me.cause{end}.message(stInd:endInd);
                    end


                    displ=strfind(a,checkBlockName);
                    if~any(displ)||(length(me.cause)==1)


                        index=find(filepath==filesep,1,'last');


                        if isempty(index)
                            index=1;
                        end

                        filepathNew=strrep(filepath,'\','\\');
                        if~isempty(me.cause{end}.cause)
                            lineNum=me.cause{end}.cause{i}.stack(1).line;
                        else
                            lineNum=me.cause{end}.stack(1).line;
                        end
                        if~isempty(filepathNew)
                            msg=sprintf(['See file <a href = "matlab:open(',sprintf('''%s'')"',filepathNew),'>%s</a> at line %d.'],filepath(index+1:end),lineNum);
                            msg=strrep(msg,'\','\\');
                        else
                            msg='';
                        end
                    else
                        msg='';
                    end
                else

                    msg='';
                    displ=0;
                    filepath='';
                end

                if~any(strfind(filepath,'.sscp'))
                    if~isempty(me.cause{end}.cause)
                        if~isempty(msg)
                            b1=[b1,me.cause{end}.cause{i}.message,msg,'<br>'];
                        end
                    else
                        b=[b,me.cause{end}.message,'. ',msg];
                    end
                else

                    if~isempty(me.cause{end}.cause)

                        if numel(strLink1)==1&&strFlag1
                            b1=[b1,me.cause{end}.cause{i}.message,me.cause{end}.message,'<br>'];
                            strFlag1=0;
                        else

                            ind=strcmp(me.cause{end}.cause{i}.message,strLink1);
                            if strFlag1(ind)
                                strFlag1(ind)=0;
                                charMsg=char(strLink1(ind));
                                colonIdx=strfind(charMsg,':');
                                b1=[b1,charMsg(1:colonIdx(end)-1),'<br>'];
                            end
                        end
                    end
                end
            end
            if~isempty(b1)
                if~any(strfind(b1,me.cause{end}.message))
                    b1=[me.cause{end}.message,'<br>',b1];
                end
                if isempty(b)
                    b=b1;
                else
                    b=[b,'<br',b1];
                end
            else
                if isempty(me.cause{end}.cause)
                    if isempty(b)
                        b=me.cause{end}.message;
                    end
                else
                    b='';
                end
            end
            if~isempty(a)
                addBR='<br>';
            else
                addBR='';
            end
            c=[a,addBR,b];

            me=MException('checkSwitchedLinear:getDynamicSystem',c);
            throwAsCaller(me);
        else
            me=MException('checkSwitchedLinear:getDynamicSystem',me.message);
            throwAsCaller(me);
        end
    end
end
