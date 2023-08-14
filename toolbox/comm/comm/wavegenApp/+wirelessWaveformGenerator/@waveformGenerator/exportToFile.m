function exportToFile(obj,~)




    filterSpec={'*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'));...
    '*.bb',getString(message('comm:waveformGenerator:Basebandfiles'))};
    [filename,pathname]=uiputfile(filterSpec);

    if filename==0
        return
    end
    file=fullfile(pathname,filename);


    obj.setStatus(getString(message('comm:waveformGenerator:Exporting')));

    if endsWith(file,'mat')

        waveStruct.type=obj.pCurrentWaveformType;
        waveStruct.config=obj.pWaveformConfiguration;
        waveStruct.Fs=obj.pSampleRate;
        waveStruct.impairments=obj.pGenerationImpairments;
        waveStruct.waveform=obj.pWaveform;
        waveStruct=obj.pParameters.CurrentDialog.appendExportData(waveStruct);
        save(file,'waveStruct');

        obj.setStatus(getString(message('comm:waveformGenerator:Exported2File',obj.pCurrentWaveformType,'MAT')));

    elseif endsWith(file,'bb')

        freq=0;

        meta.Type=obj.pCurrentWaveformType;
        s=obj.pWaveformConfiguration;

        fields=fieldnames(s);
        s=rmfield(s,fields(endsWith(fields,'_Values')));
        if~isempty(obj.pGenerationImpairments)
            s.impairments=obj.pGenerationImpairments;
        end
        s=obj.pParameters.CurrentDialog.appendExportData(s);
        meta=flattenStruct(s,meta,false);
        bbWriter=comm.BasebandFileWriter(file,obj.pSampleRate,freq,...
        'Metadata',meta);
        if~isempty(obj.pWaveform)
            bbWriter(obj.pWaveform);
        end
        release(bbWriter);

        obj.setStatus(getString(message('comm:waveformGenerator:Exported2File',obj.pCurrentWaveformType,'BB')));
    end

    function meta=flattenStruct(s,meta,inImpairStruct,varargin)



        if iscell(s)
            anObj=s{1};
            props=properties(anObj);
            for idx=1:numel(props)
                vec=nan(1,numel(s));
                for idx2=1:numel(s)
                    if isnumeric(s{idx2}.(props{idx}))&&isscalar(s{idx2}.(props{idx}))
                        vec(idx2)=s{idx2}.(props{idx});
                    end
                end
                meta.([varargin{1},'_',props{idx}])=vec;
            end
            return
        end

        fns=fieldnames(s);
        s=rmfield(s,fns(endsWith(fns,'_Values')));
        fns=fieldnames(s);
        for idx=1:length(fns)
            v=s.(fns{idx});

            if~isstruct(v)&&~isobject(v)&&~iscell(v)
                if~inImpairStruct
                    if~isempty(v)
                        meta.(fns{idx})=v;
                    else
                        meta.(fns{idx})='[]';
                    end
                else
                    impairmentName=varargin{1};
                    meta.([impairmentName,fns{idx}])=v;
                end
            else
                isImpairStruct=strcmp(fns{idx},'impairments');
                if isa(v,'matlab.System')
                    v=get(v);
                elseif isobject(v)
                    warning('OFF','MATLAB:structOnObject')
                    v=struct(v);
                    warning('ON','MATLAB:structOnObject')
                end
                meta=flattenStruct(v,meta,isImpairStruct|inImpairStruct,fns{idx});
            end
        end


