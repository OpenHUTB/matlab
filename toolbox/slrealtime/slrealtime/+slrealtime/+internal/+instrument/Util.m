classdef Util






    methods(Static)


        function[signals]=checkAndFormatSignalArgs(varargin)
            nargs=length(varargin);
            if nargs==1
                if isa(varargin{1},'slrealtime.Instrument')



                    inst=varargin{1};
                    nsigs=length(inst.signals);
                    blockpaths=cell(1,nsigs);
                    portindices=cell(1,nsigs);
                    signames=cell(1,nsigs);
                    statenames=cell(1,nsigs);
                    decimations=cell(1,nsigs);
                    metadatas=cell(1,nsigs);

                    for i=1:nsigs
                        blockpaths{i}=inst.signals(i).blockpath.convertToCell();
                        portindices{i}=inst.signals(i).portindex;
                        signames{i}=inst.signals(i).signame;
                        statenames{i}=inst.signals(i).statename;
                        decimations{i}=inst.signals(i).decimation;
                        metadatas{i}=inst.signals(i).metadata;
                    end
                elseif isstruct(varargin{1})


                    st=varargin{1};
                    if isfield(st,'blockpath')&&isfield(st,'portindex')&&isfield(st,'signame')&&isfield(st,'statename')
                        blockpaths={st.blockpath};
                        portindices={st.portindex};
                        signames={st.signame};
                        statenames={st.statename};
                        decimations={1};
                        if isfield(st,'metadata')
                            metadatas={st.metadata};
                        else
                            metadatas={[]};
                        end
                    else
                        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                    end
                else




                    inputsignames=varargin{1};
                    if ischar(inputsignames)
                        nSigs=1;
                        inputsignames={inputsignames};
                    else
                        nSigs=length(inputsignames);
                    end
                    blockpaths=cell(1,nSigs);
                    portindices=cell(1,nSigs);
                    signames=cell(1,nSigs);
                    statenames=cell(1,nSigs);
                    decimations=cell(1,nSigs);
                    metadatas=cell(1,nSigs);

                    iscellarray=iscell(inputsignames);
                    for i=1:nSigs
                        if iscellarray
                            signame=convertStringsToChars(inputsignames{i});
                        else
                            signame=convertStringsToChars(inputsignames(i));
                        end
                        if isempty(signame)||~ischar(signame)
                            slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                        end
                        blockpaths{i}='';
                        portindices{i}=-1;
                        signames{i}=signame;
                        statenames{i}='';
                        decimations{i}=1;
                        metadatas{i}={[]};
                    end
                end
            elseif nargs==2


                blockpath=varargin{1};
                portindexOrStatename=varargin{2};

                if isempty(blockpath)||isempty(portindexOrStatename)
                    slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                end


                if iscell(blockpath)
                    blockpath=cellfun(@convertStringsToChars,blockpath,'UniformOutput',false);
                    if any(cellfun(@isempty,blockpath))||~all(cellfun(@ischar,blockpath))
                        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                    end
                elseif length(blockpath)>1&&isstring(blockpath(1))
                    blockpath=arrayfun(@convertStringsToChars,blockpath,'UniformOutput',false);
                    if any(cellfun(@isempty,blockpath))||~all(cellfun(@ischar,blockpath))
                        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                    end
                else
                    blockpath=convertStringsToChars(blockpath);
                    if~ischar(blockpath)
                        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                    end
                end


                portindex=-1;
                statename='';
                if isnumeric(portindexOrStatename)
                    portindex=portindexOrStatename;
                    if length(portindex)>1
                        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                    end
                else
                    statename=convertStringsToChars(portindexOrStatename);
                    if isempty(statename)||~ischar(statename)
                        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                    end
                end

                blockpaths={blockpath};
                portindices={portindex};
                signames={''};
                statenames={statename};
                decimations={1};
                metadatas={[]};
            else
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end

            signals=[];
            for i=1:length(blockpaths)
                blockpath=blockpaths{i};
                portindex=portindices{i};
                signame=signames{i};
                statename=statenames{i};
                decimation=decimations{i};
                metadata=metadatas{i};


                signal=struct(...
                'blockpath',Simulink.SimulationData.BlockPath(blockpath),...
                'portindex',portindex,...
                'signame',signame,...
                'statename',statename,...
                'metadata',metadata,...
                'decimation',decimation,...
                'type',slrealtime.internal.instrument.SignalTypes.Badged);
                signals=[signals,signal];%#ok 
            end
        end
    end
end