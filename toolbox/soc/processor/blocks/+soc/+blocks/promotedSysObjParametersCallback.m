function promotedSysObjParametersCallback(CurrentBlock,ParameterName,ExcludeParameters)%#ok<INUSL>



    if nargin<3
        ExcludeParameters=[];
    else
        ExcludeParameters=convertCharsToStrings(ExcludeParameters);
        validateattributes(ExcludeParameters,{'char','string'},{'nonempty'},'promotedSysObjParametersCallback','ExcludeParameters',3);
    end

    if isequal(get_param(bdroot(CurrentBlock),'SimulationStatus'),'stopped')

        CurrentBlockPath=sprintf('%s/%s',get_param(CurrentBlock,'Parent'),get_param(CurrentBlock,'Name'));

        LowerBlockPath=sprintf('%s/%s',CurrentBlockPath,get_param(CurrentBlock,'hoistedMaskSrc'));

        CurrentBlockMask=Simulink.Mask.get(CurrentBlock);

        LowerBlockMask=Simulink.Mask.get(LowerBlockPath);
        PropNames={LowerBlockMask.Parameters.Name};


        matlabsystem=get_param(LowerBlockPath,'System');

        ChangeVisibility=false;
        if exist(matlabsystem,'class')

            swarn=warning('off');
            cleanupObj=onCleanup(@()warning(swarn));
            try

                sysobj=eval(matlabsystem);
                sysobjProps=properties(sysobj);
                idxs=find(ismember({CurrentBlockMask.Parameters.Name},sysobjProps));


                for j=1:numel(idxs)
                    i=idxs(j);
                    ParamName=CurrentBlockMask.Parameters(i).Name;

                    try
                        if isprop(sysobj,ParamName)&&~isInactiveProperty(sysobj,ParamName)
                            if isequal(CurrentBlockMask.Parameters(i).Evaluate,'on')

                                propvalue=slResolve(get_param(CurrentBlock,ParamName),CurrentBlock);
                            else
                                propvalue=get_param(CurrentBlock,ParamName);

                                if isequal(LowerBlockMask.Parameters(ismember(PropNames,ParamName)).Type,'checkbox')
                                    propvalue=isequal(propvalue,'on');
                                end
                            end
                            if~isempty(propvalue)
                                set(sysobj,ParamName,propvalue);
                            end
                        end
                        ChangeVisibility=true;
                    catch
                    end
                end
            catch exc %#ok<NASGU>

            end
        end
        if ChangeVisibility
            for i=1:numel(CurrentBlockMask.Parameters)
                ParamName=CurrentBlockMask.Parameters(i).Name;


                if isprop(sysobj,ParamName)&&~(~isempty(ExcludeParameters)&&contains(ParamName,ExcludeParameters))
                    if~isInactiveProperty(sysobj,ParamName)
                        CurrentBlockMask.Parameters(i).Visible='on';
                        CurrentBlockMask.Parameters(i).Enabled='on';
                    else
                        CurrentBlockMask.Parameters(i).Visible='off';
                        CurrentBlockMask.Parameters(i).Enabled='off';
                    end
                end
            end
        end
    end
end

