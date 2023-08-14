function[resolution,isExists]=slResolve(expr,context,return_mode,resolution_mode)


























































    persistent RESOLVER;

    if(nargin<3)

        return_mode='expression';
    elseif~ismember(return_mode,{'expression','variable','context','context_private','original_context'})
        DAStudio.error('Simulink:Parameters:SlResolveInvalidReturnMode');
    end

    if(nargin<4)

        resolution_mode='hierarchical';
    elseif~ismember(resolution_mode,{'hierarchical','base','startUnderMask','startAboveMask'})
        DAStudio.error('Simulink:Parameters:SlResolveInvalidResolutionMode');
    end

    if(~ischar(expr))
        DAStudio.error('Simulink:Parameters:SlResolveInvalidArgType','EXPR')
    end

    if(~ischar(context)&&~ishandle(context))
        DAStudio.error('Simulink:Parameters:SlResolveInvalidContextArgType','CONTEXT');
    end

    if(~ischar(resolution_mode))
        DAStudio.error('Simulink:Parameters:SlResolveInvalidArgType','RESOLUTION_MODE');
    end

    if(~ischar(return_mode))
        DAStudio.error('Simulink:Parameters:SlResolveInvalidArgType','RETURN_MODE');
    end






    if isempty(RESOLVER)
        RESOLVER=get_param('built-in/S-Function','Resolver');
    end;

    if slfeature('ExplicitDataLinks')>0
        if isvarname(expr)

            mdlName=bdroot(context);
            ds=get_param(mdlName,'DictionarySystem');


            keyIndex=find(contains(ds.ExplicitDataLinkMap.keys,context));
            if~isempty(keyIndex)
                assert(numel(keyIndex)==1,'Multiple matching keys not supported in this prototype')
                key=ds.ExplicitDataLinkMap.keys{1};
                mf0Entry=ds.ExplicitDataLinkMap.getByKey(key);

                if(strcmp(expr,mf0Entry.IDinSection))

                    if strcmp(mf0Entry.DataSource,'base workspace')
                        if strcmp(return_mode,'original_context')



                            resolution='Global';
                        else
                            try
                                resolution=evalin('base',expr);
                                isExists=1;
                            catch E


                            end

                        end
                    elseif strcmp(mf0Entry.DataSource,'model workspace')
                        dataAccessor=Simulink.data.DataAccessor.createForLocalData(bdroot(context));
                        varID=dataAccessor.name2UniqueID(expr);
                        resolution=dataAccessor.getVariable(varID);
                        isExists=1;
                    elseif contains(mf0Entry.DataSource,'.sldd')
                        dataAccessor=Simulink.data.DataAccessor.createForOutputData(mf0Entry.DataSource);


                        varID=dataAccessor.name2UniqueID(expr);
                        resolution=dataAccessor.getVariable(varID);
                        isExists=1;
                    else

                        disp('Direct links prototype does not support other workspaces.');
                    end
                end
            end
        end

        if(isExists)

            return
        end




    end

    try
        resolution=mexResolveNameInBlock(expr,context,...
        RESOLVER,...
        return_mode,...
        resolution_mode);
        if(nargout>1)
            isExists=1;
        end
    catch e
        if(nargout==1)
            if recursivelySearchID(e)
                e.rethrow;
            elseif isequal(return_mode,'context_private')||...
                isequal(return_mode,'original_context')

                slsvInternal('slsvHandleMException',e,-1);
            else
                warning OFF BACKTRACE;

                slsvInternal('slsvHandleMException',e,1);
                warning ON BACKTRACE;
                ME=MException('Simulink:Data:SlResolveNotResolved',...
                ['Can not resolve: ',expr,'.']);
                ME.throw;
            end
        else
            resolution=[];
            isExists=0;
        end
    end
end


function idFound=recursivelySearchID(e)




    idFound=false;
    if isempty(e.cause)
        if isequal(e.identifier,'Simulink:Data:SlResolveNotResolved')
            idFound=true;
            return;
        end
    else
        for i=1:numel(e.cause)
            idFound=recursivelySearchID(e.cause{i});
        end
    end
end


