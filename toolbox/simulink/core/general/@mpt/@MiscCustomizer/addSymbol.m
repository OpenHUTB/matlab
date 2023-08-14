function addSymbol(hThisObj,symbolName,varargin)




    if~isprop(hThisObj,'MPFSymbolDefinition')
        persistent diswarn
        if isempty(diswarn)
            MSLDiagnostic('Simulink:mpt:MPTMiscAddSymbol').reportAsWarning;
            diswarn=1;
        end
        return
    end


    if ischar(symbolName)&&length(varargin)>1&&rem(length(varargin),2)==0
        existCusSymbolList=sl_get_customization_param(hThisObj,'MPFSymbolDefinition');
        oldList=hThisObj.MPFSymbolDefinition;

        [tf,loc]=ismember(symbolName,existCusSymbolList);
        fn=mfilename;
        if~tf

            symbol=mpt.SymbolDefinition;
            symbol.Name=symbolName;
            [symbol,status]=update_object_prop(symbol,varargin,fn);

            if status==1
                hThisObj.MPFSymbolDefinition={symbol,oldList{:}};
            end
        else

            symbol=oldList{loc};
            [symbol,status]=update_object_prop(symbol,varargin,fn);

            if status==1
                hThisObj.MPFSymbolDefinition{loc}=symbol;
            end
        end
    else
        MSLDiagnostic('Simulink:mpt:MPTInvalidInputArg',mfilename).reportAsWarning;
    end


    function[hobj,status]=update_object_prop(hobj,propValuePair,fn)


        status=1;

        try

            oldPropList=getProperty(hobj,'Property');

            oldPropNameList={};
            for i=1:length(oldPropList)
                oldPropNameList{end+1}=oldPropList{i}{1};
            end



            if~iscellstr(propValuePair{1})
                if~iscell(propValuePair{1})

                    propList={};
                    valueList={};
                    for i=1:2:(length(propValuePair)-1)
                        propList{end+1}=propValuePair{i};
                        valueList{end+1}=propValuePair{i+1};
                    end

                    if~iscellstr(propList)
                        MSLDiagnostic('Simulink:mpt:MPTInvalidInputArg',fn).reportAsWarning;
                        status=0;
                        return
                    end
                else


                    MSLDiagnostic('Simulink:mpt:MPTInvalidInputArg',fn).reportAsWarning;
                    status=0;
                    return
                end
            else


                propList=propValuePair{1};
                valueList=propValuePair{2};
            end



            if isUnique(propList)

                addList={};
                for i=1:length(propList)


                    [tf,loc]=ismember(propList{i},oldPropNameList);
                    if tf

                        oldPropList{loc}{2}=valueList{i};
                    else

                        addList={addList{:},{propList{i},valueList{i}}};
                    end
                end
                setProperty(hobj,'Property',{oldPropList{:},addList{:}});
            else

                MSLDiagnostic('Simulink:mpt:MPTInvalidInputArg',fn).reportAsWarning;
                status=0;
            end
        catch ME
            MSLDiagnostic('Simulink:mpt:MPTSLGenMsg',ME.message).reportAsWarning;
        end


        function tf=isUnique(cellString)


            new=unique(cellString);
            tf=isequal(new,sort(cellString));
