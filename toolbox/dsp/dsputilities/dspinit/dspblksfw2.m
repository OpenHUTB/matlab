function varargout=dspblksfw2(action,varargin)




    blkh=gcbh;

    if nargin==0
        action='dynamic';
    end

    switch action
    case 'init'
        fullblk=getfullname(blkh);
        FromWorks_blk=[fullblk,'/From Workspace'];
        ExtendOutput=get_param(fullblk,'OutputAfterFinalValue');


        if~strcmp(get_param(FromWorks_blk,'OutputAfterFinalValue'),ExtendOutput)
            try %#ok






                set_param(FromWorks_blk,'OutputAfterFinalValue',ExtendOutput);
            end
        end

        varargout=initBlock(fullblk,ExtendOutput,varargin);

    case 'dynamic'
        old_mask_visibles=get_param(blkh,'MaskVisibilities');
        new_mask_visibles=old_mask_visibles;

        if~(strcmp(get_param(blkh,'OutputAfterFinalValue'),'Cyclic repetition'))
            new_mask_visibles{5}='off';
        else
            new_mask_visibles{5}='on';
        end

        if~(isequal(new_mask_visibles,old_mask_visibles))
            set_param(blkh,'MaskVisibilities',new_mask_visibles);
        end

    end



    function argsOut=initBlock(fullblk,ExtendOutput,argsIn)

        if(strcmp(get_param(bdroot(gcs),'SimulationStatus'),'initializing'))
            if isempty(argsIn{1}),error(message('dsp:dspblksfw2:paramEmptyError1'));end
            if isempty(argsIn{2}),error(message('dsp:dspblksfw2:paramEmptyError2'));end
            if isempty(argsIn{3}),error(message('dsp:dspblksfw2:paramEmptyError3'));end
        end

        X=argsIn{1};

        if isa(X,'timeseries')
            error(message('dsp:dspblksfw2:TimeseriesNotAllowed'));
        end

        if(isstruct(X))
            error(message('dsp:dspblksfw2:StructNotAllowed'));
        end

        Ts=double(argsIn{2});
        nSamps=double(argsIn{3});


        setOutputFrameStatus(fullblk,X,nSamps);

        if isempty(X)||isempty(Ts)||isempty(nSamps)



            s.time=[];
            s.signals.values=0;
            s.signals.dimensions=[1,1];

            newTs=Ts;

        else
            if(ndims(X)>3)
                error(message('dsp:dspblksfw2:GreaterThan3DSignalsNotAllowed'));
            end
            if nSamps<=0
                error(message('dsp:dspblksfw2:paramOutOfRange1'));
            end

            if(Ts<=0)&&(Ts~=-1)
                error(message('dsp:dspblksfw2:paramOutOfRange2'));
            end


            s=PrepareDataForFromWorkspace(fullblk,X,nSamps,ExtendOutput);

            if(exist_block(fullblk,'Buffer'))
                newTs=Ts;
                if(Ts<0)



                    error(message('dsp:dspblksfw2:paramOutOfRange3'));
                end
            else

                if(Ts>=0)
                    newTs=Ts*nSamps;
                else
                    newTs=Ts;
                end
            end
        end

        argsOut(1:2)={s,newTs};



        function s=PrepareDataForFromWorkspace(fullblk,X,nSamps,ExtendOutput)

            makeItComplex=0;
            if~(isreal(X))
                makeItComplex=1;
            end

            if ndims(X)==3


                if nSamps~=1
                    error(message('dsp:dspblksfw2:paramOutOfRange4'));
                end

                [outRows,outCols,~]=size(X);
                UU=X;
            else




                outRows=nSamps;

                [xRows,xCols]=size(X);


                if(xRows==1)
                    xRows=xCols;
                    xCols=1;
                    X=X(:);
                end

                switch ExtendOutput
                case 'Setting to zero'
                    [UU,outCols]=reshape2D(X,nSamps);

                    remove_Buffer(fullblk);

                case 'Cyclic repetition'





                    if(xRows>nSamps)
                        R=mod(xRows,nSamps);
                    else
                        R=nSamps-xRows;
                    end

                    if(R==0)||(nSamps==1)
                        [UU,outCols]=reshape2D(X,nSamps);


                        remove_Buffer(fullblk);

                    else





                        fullblk_nonewline=strrep(fullblk,newline,' ');
                        diagnostic_setting=get_param(fullblk,...
                        'ignoreOrWarnInputAndFrameLengths');

                        if strcmp(diagnostic_setting,'on')
                            s=warning('query','backtrace');
                            warning off backtrace;
                            warning(message('dsp:SignalFromWorkspace:Multirate',...
                            fullblk_nonewline));
                            warning(s);
                        end

                        if(xRows>nSamps)
                            IC=X(1:nSamps,:);

                            UUU=[X(nSamps+1:end,:);X(1:nSamps,:)].';
                            UU=reshape(UUU,1,xCols,[]);
                        else
                            rep=ceil(nSamps/xRows);
                            UU=repmat(X,rep,1);
                            IC=UU(1:nSamps,:);
                            UUU=[UU(nSamps+1:end,:);UU(1:R,:)].';
                            UU=reshape(UUU,1,xCols,[]);
                        end

                        outRows=1;
                        outCols=xCols;

                        insert_Buffer(fullblk,IC);
                    end

                case 'Holding final value'
                    [UU,outCols]=reshape2D(X,nSamps);







                    remove_Buffer(fullblk);

                    lastRow=X(end,:);

                    if(xRows>nSamps)

                        R=mod(xRows,nSamps);
                        if(R>0)

                            UU(R+1:end,:,end)=lastRow(ones(nSamps-R,1),:);
                        end

                        UU(:,:,end+1)=lastRow(ones(nSamps,1),:);

                    else



                        R=nSamps-xRows;
                        if(R>0)

                            UU(end-R+1:end,:)=lastRow(ones(R,1),:);
                        end

                        [mm,nn,ll]=size(UU);
                        UU(1:mm,1:nn,ll+1)=lastRow(ones(nSamps,1),:);
                    end

                end

            end


            s.time=[];
            if makeItComplex&&isreal(UU)
                s.signals.values=complex(UU);
            else
                s.signals.values=UU;
            end
            s.signals.dimensions=[outRows,outCols];



            function[UU,nChans]=reshape2D(U,nSamps)




                [m,n]=size(U);

                nChans=size(U,2);


                UU=U(1);

                if(nSamps==1)


                    UU(1,1:n,1:m)=U.';

                else

                    if(m==1)||(n==1)

                        UU(1:nSamps,1,1:ceil(m*n/nSamps))=buffer(U(:,1),nSamps);
                    else

                        U=reshape(U.',m*n,1);
                        V=buffer(U,nChans*nSamps);


                        nSteps=size(V,2);
                        if(nSteps<nChans)
                            for i=1:nSteps
                                UU(1:nSamps,1:nChans,i)=reshape(V(:,i),nChans,nSamps).';
                            end
                        else
                            for i=1:nChans
                                UU(1:nSamps,i,1:nSteps)=V(i:nChans:nChans*nSamps,:);
                            end
                        end
                    end
                end



                function setOutputFrameStatus(fullblk,X,nSamps)

                    frame_conv_blk=[fullblk,'/Frame Status'];
                    frameStr=get_param(frame_conv_blk,'OutFrame');
                    params=get_param(fullblk,'DialogParameters');
                    if isfield(params,'OutputFrames')
                        outputFramesStr=get_param(fullblk,'OutputFrames');
                    else
                        outputFramesStr='on';
                    end

                    if(nSamps>1)&&(ndims(X)~=3)
                        if strcmp(outputFramesStr,'on')
                            if~strcmp(frameStr,'Frame-based')
                                set_param(frame_conv_blk,'OutFrame','Frame based');
                            end
                        else
                            set_param(frame_conv_blk,'OutFrame','Sample based');
                        end
                    else
                        if~strcmp(frameStr,'Sample-based')
                            set_param(frame_conv_blk,'OutFrame','Sample based');
                        end
                    end



                    function insert_Buffer(fullblk,IC)


                        buffer_blk=[fullblk,'/Buffer'];

                        if~exist_block(fullblk,'Buffer')
                            delete_line(fullblk,'From Workspace/1','Frame Status/1');
                            load_system('dspbuff3');
                            add_block('dspbuff3/Buffer',buffer_blk);

                            set_param(buffer_blk,'Position',[140,20,190,70]);

                            add_line(fullblk,'From Workspace/1','Buffer/1');
                            add_line(fullblk,'Buffer/1','Frame Status/1');

                        end


                        set_param(buffer_blk,'ic',mat2str(double(IC)));
                        set_param(buffer_blk,'N',mat2str(size(IC,1)));



                        function remove_Buffer(fullblk)


                            if exist_block(fullblk,'Buffer')
                                delete_line(fullblk,'From Workspace/1','Buffer/1');
                                delete_line(fullblk,'Buffer/1','Frame Status/1');
                                delete_block([fullblk,'/Buffer']);
                                add_line(fullblk,'From Workspace/1','Frame Status/1')
                            end
