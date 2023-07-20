function importLegacyMS(sourceDD,package)









    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    legacyMSs=processcsc('GetMemorySectionDefns',package);
    if~isempty(legacyMSs)
        dd=hlp.openDD(sourceDD);
        for i=1:length(legacyMSs)

            if strcmp(legacyMSs(i).Name,'Default')
                continue;
            end
            msName=[package,'_',legacyMSs(i).Name];
            msEntry=hlp.findEntry(dd,'AbstractMemorySection',msName);
            if isempty(msEntry)
                msEntry=hlp.createEntry(dd,'LegacyMemorySection',msName);
            end
            hlp.setProp(msEntry,'Package',package);
            if strcmp(hlp.getProp(msEntry,'Package'),'SimulinkBuiltin')
                hlp.setProp(msEntry,'isBuiltin',true);
            end
            hlp.setProp(msEntry,'ClassName',legacyMSs(i).Name);
            if legacyMSs(i).getProp('DataUsage').IsSignal
                swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
                cats=Utils.getSignalCategories;
                for j=1:length(cats)
                    hlp.addAllowableCoderDataForElement(swc,'MemorySection',cats{j},msEntry,true);
                end
            end
            if legacyMSs(i).getProp('DataUsage').IsParameter
                swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
                cats=Utils.getParameterCategories;
                for j=1:length(cats)
                    hlp.addAllowableCoderDataForElement(swc,'MemorySection',cats{j},msEntry,true);
                end
            end


            if strcmp(hlp.getProp(msEntry,'Package'),'Simulink')
                msgID=['SimulinkCoderApp:data:',hlp.getProp(msEntry,'ClassName')];
                hlp.setProp(msEntry,'Description',...
                DAStudio.message(msgID));
            end
            locSetLegacyProps(msEntry,legacyMSs(i));

        end
    end
end

function locSetLegacyProps(entry,legacyMSDefn)


    if isempty(legacyMSDefn)
        return;
    end

    if~isempty(legacyMSDefn)
        names=fieldnames(legacyMSDefn)';
        numProps=numel(names);
        for ii=1:numProps
            prop=names{ii};
            value=legacyMSDefn.(prop);
            if isa(value,'Simulink.DataUsage')
                if value.IsParameter&&value.IsSignal
                    value='SignalOrParameter';
                elseif value.IsParameter
                    value='IsParameter';
                elseif value.IsSignal
                    value='IsSignal';
                else
                    value='---';
                end
            elseif strcmp(prop,'PostPragma')
                prop='PostStatement';
            elseif strcmp(prop,'PrePragma')
                prop='PreStatement';
            elseif strcmp(prop,'Name')

                continue;
            elseif isempty(value)
                value='---';
            elseif islogical(value)
                if value
                    value='true';
                else
                    value='false';
                end
            end
            if ischar(value)
                entry.addNonInstanceSpecificProp(prop,value);
            end
        end
    end
end
