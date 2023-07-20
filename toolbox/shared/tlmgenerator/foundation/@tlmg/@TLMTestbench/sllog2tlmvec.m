function numVectors=sllog2tlmvec(this)




















    loggedSigs={};
    if(~isempty(this.InportSrc))
        loggedSigs={loggedSigs{:},this.InportSrc.loggingPortName};%#ok<CCAT>
    end
    if(~isempty(this.OutportSnk))
        loggedSigs={loggedSigs{:},this.OutportSnk.loggingPortName};%#ok<CCAT>
    end


    l_logTypeErrorCheck(this,loggedSigs);




    samples=l_getSampleCounts(this,loggedSigs);
    numVectors=max(samples);
    l_sampleCountCheck(samples);




    tlmvec=l_dataConversion(this,loggedSigs,samples,numVectors);

    this.TlmInVec.(this.TlmInVecName)=tlmvec;

end




function l_logTypeErrorCheck(this,loggedSigs)

    slogp=this.SllogBasePath;

    logField=['this.OrigSllog.',this.OrigSllogName];
    lgobj=eval(logField);
    for ii=1:length(loggedSigs)
        sigN=loggedSigs{ii};
        slname=[slogp,'.',sigN];

        if(isa(lgobj,'Simulink.ModelDataLogs'))
            origSlField=['this.OrigSllog.',slname];
            tsobj=eval(origSlField);

            if isa(tsobj,'Simulink.TsArray')

                tsobj=tsobj.flatten;
            else
                tsobj={tsobj};
            end

            for jj=1:numel(tsobj);
                if~isa(tsobj{jj},'Simulink.Timeseries')
                    error(message('TLMGenerator:TLMTestbench:NotTsObj',sigN));
                end
            end


        elseif(isa(lgobj,'Simulink.SimulationData.Dataset'))
            origSlField=['this.OrigSllog.',this.OrigSllogName,'.getElement(''',sigN,''').Values'];
            tsobj=eval(origSlField);

            if isa(tsobj,'struct')

                tsobj=struct2cell(tsobj);
            else
                tsobj={tsobj};
            end

            for jj=1:numel(tsobj);
                if~isa(tsobj{jj},'timeseries')
                    error(message('TLMGenerator:TLMTestbench:NotTsObj',sigN));
                end
            end

        end

    end

end


function samples=l_getSampleCounts(this,loggedSigs)

    samples=zeros(1,length(loggedSigs));
    slogp=this.SllogBasePath;

    logField=['this.OrigSllog.',this.OrigSllogName];
    lgobj=eval(logField);
    for ii=1:length(loggedSigs)
        sigN=loggedSigs{ii};
        slname=[slogp,'.',sigN];
        if(isa(lgobj,'Simulink.ModelDataLogs'))
            origSlField=['this.OrigSllog.',slname];
            tsobj=eval(origSlField);

            if isa(tsobj,'Simulink.TsArray')
                tsobjcell=tsobj.flatten;
                tsobj=tsobjcell{1};
            end



            if(isa(tsobj.TimeInfo,'Simulink.FrameInfo'))
                samples(ii)=tsobj.TimeInfo.length/tsobj.TimeInfo.Framesize;
            elseif(isa(tsobj.TimeInfo,'Simulink.TimeInfo'))
                samples(ii)=tsobj.TimeInfo.length;
            else
                error(message('TLMGenerator:TLMTestbench:CantGetSamples',sigN));
            end

        elseif(isa(lgobj,'Simulink.SimulationData.Dataset'))
            origSlField=['this.OrigSllog.',this.OrigSllogName,'.getElement(''',sigN,''').Values'];
            tsobj=eval(origSlField);

            if isa(tsobj,'struct')
                tsobjcell=struct2cell(tsobj);
                tsobj=tsobjcell{1};

            end

            samples(ii)=tsobj.TimeInfo.Length;

        end

    end

end


function l_sampleCountCheck(samples)

    uniquesamples=unique(samples);






    if(~((length(uniquesamples)==1)||...
        (length(uniquesamples)==2&&~isempty(find(uniquesamples==1,1))))...
        )
        error(message('TLMGenerator:TLMTestbench:DiffNumSamples',sprintf('%d ',uniquesamples)));
    end

    if(~all(uniquesamples))
        error(message('TLMGenerator:TLMTestbench:NoData'));
    end

end


function tlmvec=l_dataConversion(this,loggedSigs,samples,numVectors)

    tlmvec=[];
    slogp=this.SllogBasePath;

    logField=['this.OrigSllog.',this.OrigSllogName];
    lgobj=eval(logField);

    for ii=1:length(loggedSigs)

        sigN=loggedSigs{ii};
        slname=[slogp,'.',sigN];
        if(isa(lgobj,'Simulink.ModelDataLogs'))
            origSlField=['this.OrigSllog.',slname];
        elseif(isa(lgobj,'Simulink.SimulationData.Dataset'))
            origSlField=['this.OrigSllog.',this.OrigSllogName,'.getElement(''',sigN,''').Values'];
        end
        tsobj=eval(origSlField);

        if isa(tsobj,'struct')||isa(tsobj,'Simulink.TsArray')
            error(message('TLMGenerator:TLMTestbench:NoBusSupport',sigN));
        end

        data1=tsobj.Data(1);
        isConst=l_isConstantSig(samples(ii),numVectors);
        isComplex=~isreal(data1);

        if(isComplex)
            error(message('TLMGenerator:TLMTestbench:IsComplex',[slogp,'.',sigN]));
        end

        if(~isnumeric(data1)&&~islogical(data1))
            error(message('TLMGenerator:TLMTestbench:ToMATNonNumeric',sigN));
        end




        tlmvec.(sigN).SampleInfo=struct(...
        'elemDataType',class(data1),...
        'elemsPerSample',prod(size(tsobj.Data))/samples(ii),...
        'numSamples',samples(ii),...
        'numVectors',numVectors,...
        'isConst',isConst);%#ok<PSIZE>

        tlmvec.(sigN).DataTypeInfo=struct(...
        'isComplex',isComplex);




        if(isa(data1,'embedded.fi'))
            elemsPerSample=tlmvec.(sigN).SampleInfo.elemsPerSample;
            intsPerElem=length(fi2sim(data1));
            intsPerSample=elemsPerSample*intsPerElem;
            elemIntType=class(fi2sim(data1));
            if(isComplex)
                tlmvec.(sigN).Data=complex(zeros([intsPerElem,elemsPerSample,numVectors],elemIntType));
            else
                tlmvec.(sigN).Data=zeros([intsPerElem,elemsPerSample,numVectors],elemIntType);
            end

            for kk=1:samples(ii)
                for ll=1:elemsPerSample
                    origDataIdx=(elemsPerSample*(kk-1))+(ll);
                    currElem=fi2sim(tsobj.Data(origDataIdx));
                    for mm=1:intsPerElem
                        newDataIdx=(intsPerSample*(kk-1))+(intsPerElem*(ll-1))+(mm);
                        tlmvec.(sigN).Data(newDataIdx)=currElem(mm);
                    end
                end
            end

            tlmvec.(sigN).DataTypeInfo.numerictype=struct(data1.numerictype);
            tlmvec.(sigN).SampleInfo.intsPerElem=intsPerElem;
            tlmvec.(sigN).SampleInfo.elemIntType=elemIntType;



            if(isConst)
                tlmvec.(sigN).Data(:,:,2:end)=repmat(tlmvec.(sigN).Data(:,:,1),[1,1,numVectors-1]);
            end


        elseif(isa(data1,'logical'))
            elemsPerSample=tlmvec.(sigN).SampleInfo.elemsPerSample;
            intsPerElem=1;
            elemIntType='uint8';
            tlmvec.(sigN).Data=zeros([intsPerElem,elemsPerSample,numVectors],elemIntType);

            for kk=1:samples(ii)
                for ll=1:elemsPerSample
                    didx=(elemsPerSample*(kk-1))+(ll);
                    tlmvec.(sigN).Data(didx)=uint8(tsobj.Data(didx));
                end
            end

            tlmvec.(sigN).SampleInfo.intsPerElem=intsPerElem;
            tlmvec.(sigN).SampleInfo.elemIntType=elemIntType;



            if(isConst)
                tlmvec.(sigN).Data(:,:,2:end)=repmat(tlmvec.(sigN).Data(:,:,1),[1,1,numVectors-1]);
            end

        else
            if(isConst)
                tlmvec.(sigN).Data=repmat(tsobj.Data,[size(tsobj.Data),numVectors]);
            else
                tlmvec.(sigN).Data=tsobj.Data;
            end
        end

    end

end

function isConst=l_isConstantSig(numSamples,numVectors)
    if(numSamples==1&&numVectors>=2)
        isConst=true;
    else
        isConst=false;
    end
end