function load(this,fileName,varargin)

    webhmi=load(fileName);


    if isfield(webhmi,'Bindings')
        if nargin>2
            locDeserialize(this,webhmi.Bindings,false,varargin{1});
        else
            locDeserialize(this,webhmi.Bindings,false);
        end
    end


    if isfield(webhmi,'LibBindings')
        if nargin>2
            locDeserialize(this,webhmi.LibBindings,true,varargin{1});
        else
            locDeserialize(this,webhmi.LibBindings,true);
        end
    end
end

function locDeserialize(webhmiObj,bindings,isLibWidget,varargin)
    numBindings=length(bindings);
    if~isfield(bindings,'ShowInitialText')
        for idx=1:numBindings
            bindings(idx).ShowInitialText=true;
        end
    end

    for idx=1:numBindings
        if ischar(bindings(idx).BlockPath)
            import Simulink.HMI.BlockPathUtils;
            bpath=[webhmiObj.Model,'/',bindings(idx).BlockPath];
            bindings(idx).BlockPath=BlockPathUtils.createPathFromMetaData(...
            {bindings(idx).BlockPath},{get_param(bpath,'SID')},'');
        else
            bpath=[webhmiObj.Model,'/',bindings(idx).BlockPath.getBlock(1)];
        end

        try
            refBlock=get_param(bpath,'ReferenceBlock');
            if isempty(refBlock)


                try
                    set_param(bpath,'HMISrcModelName',webhmiObj.Model);
                catch
                end
            end
        catch

        end


        if~isempty(bindings(idx).Source)&&...
            isstruct(bindings(idx).Source)
            try
                handle=get_param([webhmiObj.Model,'/',bindings(idx).Source.BlockPath{1}],'Handle');
                bindings(idx).Source.CachedBlockHandle_=handle;
            catch me %#ok<NASGU>
                bindings(idx).Source.CachedBlockHandle_=0;
            end
            if~isempty(bindings(idx).Source.SSID)&&~isempty(bindings(idx).Source.SSID{1})
                sid=bindings(idx).Source.SSID{1};
                if isletter(sid(1))
                    strIdx=strfind(sid,':');
                    if~isempty(strIdx)
                        bindings(idx).Source.SSID={sid(strIdx(1)+1:end)};
                    end
                end
            elseif bindings(idx).Source.CachedBlockHandle_~=0
                bindings(idx).Source.SSID=...
                {get_param(bindings(idx).Source.CachedBlockHandle_,'SID')};
            end
        end


        if~slsvTestingHook('DisableDashboardBlockForwarding')
            if~isLibWidget
                widget=jsondecode(bindings(idx).Widget);
            else
                widget=jsondecode(bindings(idx).LibraryWidget);
            end

            Simulink.HMI.addReplacementEntry(webhmiObj.Model,...
            bpath,widget.id,widget.type,isLibWidget);
        end


        if(isLibWidget)
            if nargin>3
                webhmiObj.deserializeLibraryInstance(bindings(idx),varargin{1});
            else
                webhmiObj.deserializeLibraryInstance(bindings(idx));
            end
        else
            if nargin>3
                webhmiObj.deserialize(bindings(idx),varargin{1});
            else
                webhmiObj.deserialize(bindings(idx));
            end
        end
    end
end

