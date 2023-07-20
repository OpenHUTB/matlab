function msgs=detectEntryPointsCallingEachother(entryPoints,fcnRegistry)

    msgs=coder.internal.lib.Message.empty();

    if~iscell(entryPoints)||numel(entryPoints)==1

        return;
    end


    for ii=1:numel(entryPoints)
        fcnInfos=fcnRegistry.getFunctionTypeInfosByName(entryPoints{ii});
        for jj=1:length(fcnInfos)
            fcnInfo=fcnInfos{jj};
            if fcnInfo.isDesign
                ep_msgs=checkIfEntryPointCallsOtherEntryPoints(fcnInfo);
                if~isempty(ep_msgs)
                    msgs=[msgs,ep_msgs];
                end
            else

            end
        end
    end
end

function msgs=checkIfEntryPointCallsOtherEntryPoints(entryPointFcnInfo)
    msgs=coder.internal.lib.Message.empty();

    workList={entryPointFcnInfo};
    visited=containers.Map();
    while~isempty(workList)
        fcn=workList{1};
        workList(1)=[];
        if~visited.isKey(fcn.uniqueId)
            tree=fcn.tree.wholetree;
            attribs=fcn.treeAttributes;
            N=tree.count;
            for ii=1:N
                node=tree.select(ii);
                callee=attribs(node).CalledFunction;
                if~isempty(callee)

                    if callee.isDesign
                        messageObj=message('Coder:FXPCONV:MEPCallToEntryPoint');

                        leftPos=node.lefttreepos;
                        len=node.righttreepos-leftPos+1;
                        msg=coder.internal.lib.Message();
                        msg.functionName=fcn.functionName;%#ok<*AGROW>                    
                        msg.specializationName=fcn.specializationName;%#ok<*AGROW>
                        msg.file=fcn.scriptPath;
                        msg.type='Error';
                        msg.position=leftPos-1;
                        msg.length=len;
                        msg.text=messageObj.getString();
                        msg.id=messageObj.Identifier;
                        msgs(end+1)=msg;
                    end
                    workList{end+1}=callee;
                end
            end
            visited(fcn.uniqueId)=true;
        end
    end
end

