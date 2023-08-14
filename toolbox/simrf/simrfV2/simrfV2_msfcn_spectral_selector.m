function simrfV2_msfcn_spectral_selector(block)




    setup(block);



    function setup(block)


        block.NumInputPorts=2;
        block.NumOutputPorts=1;
        block.NumDialogPrms=1;



        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;

        block.InputPort(1).DirectFeedthrough=true;
        block.InputPort(1).SampleTime=[-1,0];
        block.InputPort(1).Complexity='Inherited';
        block.InputPort(2).SampleTime=[-1,0];
        block.InputPort(2).Complexity='Real';
        block.OutputPort(1).SampleTime=[-1,0];
        block.OutputPort(1).Complexity='Real';



        block.SimStateCompliance='DefaultSimState';


        block.RegBlockMethod('SetInputPortSampleTime',@SetInpPortST);
        block.RegBlockMethod('SetOutputPortSampleTime',@SetOutPortST);
        block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);
        block.RegBlockMethod('SetOutputPortDimensions',@SetOutPortDims);
        block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
        block.RegBlockMethod('InitializeConditions',@InitConditions);
        block.RegBlockMethod('Outputs',@Output);
        block.RegBlockMethod('Update',@Update);




        function SetInpPortST(block,~,st)

            if st<=0
                error('This block only supports discrete sample time')
            else
                N=block.DialogPrm(1).Data;
                block.InputPort(1).SampleTime=st;
                block.InputPort(2).SampleTime=st;
                block.OutputPort(1).SampleTime=[st(1)*N,st(2)];
            end



            function SetOutPortST(block,~,st)
                if st<=0
                    error('This block only supports discrete sample time')
                else
                    N=block.DialogPrm(1).Data;
                    block.OutputPort(1).SampleTime=st;
                    block.InputPort(1).SampleTime=[st(1)/N,st(2)];
                end



                function SetInpPortDims(block,port,di)
                    block.InputPort(port).Dimensions=di;
                    if((~isempty(block.InputPort(1).Dimensions))&&...
                        (~isempty(block.InputPort(2).Dimensions)))
                        di_p1=block.InputPort(1).Dimensions;
                        di_p2=block.InputPort(2).Dimensions;
                        if length(di_p1)==1

                            if length(di_p2)==1

                                block.OutputPort(1).Dimensions=[di_p2(1),di_p1(1)];
                            else

                                if((di_p2(2)~=di_p1(1))&&(di_p2(2)~=1))
                                    error(['Index must be 1D or have a row of the size of '...
                                    ,'the data input.']);
                                end
                                block.OutputPort(1).Dimensions=[di_p2(1),di_p1(1)];
                            end
                        elseif length(di_p1)==2

                            if di_p1(1)~=1
                                error('Input must be 1D or [1xN]');
                            end

                            if(((length(di_p2)~=1)&&(di_p2(2)~=1))&&...
                                (di_p2(2)~=di_p1(2)))
                                error(['Index must be 1D, a column vector, or have the '...
                                ,'same row size as that of the data input.']);
                            end
                            block.OutputPort(1).Dimensions=[di_p2(1),di_p1(2)];
                        end
                    end




                    function SetOutPortDims(block,~,di)

                        if length(di)==2
                            block.InputPort(1).Dimensions=[1,di(2)];
                            prevDim=block.InputPort(2).Dimensions;
                            if~isempty(prevDim)
                                if length(prevDim)==1
                                    block.InputPort(2).Dimensions=di(1);
                                else
                                    block.InputPort(2).Dimensions=[di(1),prevDim(2)];
                                end
                            else
                                block.InputPort(2).Dimensions=di;
                            end
                            block.OutputPort(1).Dimensions=di;
                        end



                        function DoPostPropSetup(block)


                            N=block.DialogPrm(1).Data;
                            ncol=max(block.InputPort(1).Dimensions);


                            block.NumDworks=ncol+1;
                            block.Dwork(1).Name='index';
                            block.Dwork(1).Dimensions=1;
                            block.Dwork(1).DatatypeID=0;
                            block.Dwork(1).Complexity='Real';
                            block.Dwork(1).UsedAsDiscState=false;


                            for i=2:ncol+1
                                block.Dwork(i).Name=['y',num2str(i-1)];
                                block.Dwork(i).Dimensions=N;
                                block.Dwork(i).DatatypeID=0;
                                block.Dwork(i).Complexity=block.InputPort(1).Complexity;
                                block.Dwork(i).UsedAsDiscState=false;
                            end


                            function InitConditions(block)


                                block.Dwork(1).Data=0;
                                for colIdx=2:block.NumDworks


                                    block.Dwork(colIdx).Data(:)=complex(realmin,realmin);
                                end



                                function Update(block)

                                    if block.InputPort(1).IsSampleHit
                                        ncol=max(block.InputPort(1).Dimensions);
                                        bufferIndex=block.Dwork(1).Data;
                                        bufferIndex=bufferIndex+1;
                                        InputData=block.InputPort(1).Data;
                                        for j=1:ncol
                                            if isreal(InputData(j))


                                                InputData(j)=complex(InputData(j),realmin);
                                            end
                                            block.Dwork(j+1).Data(bufferIndex)=InputData(j);
                                        end
                                        if bufferIndex>=block.DialogPrm(1).Data
                                            bufferIndex=0;
                                        end
                                        block.Dwork(1).Data=bufferIndex;
                                    end


                                    function Output(block)

                                        bufferIndex=block.Dwork(1).Data;


                                        if block.InputPort(1).IsSampleHit
                                            if bufferIndex==0
                                                N=block.DialogPrm(1).Data;
                                                ncol=max(block.InputPort(1).Dimensions);
                                                di_p2=block.InputPort(2).Dimensions;
                                                if((length(di_p2)==1)||(di_p2(2)==1))
                                                    for j=1:ncol
                                                        fft_res=(abs(fft(block.Dwork(j+1).Data,N))/N).^2;
                                                        fft_res=fft_res+(fft_res<realmin).*(realmin-fft_res);
                                                        fullVec=10*log10(fft_res)+30;
                                                        block.OutputPort(1).Data(:,j)=...
                                                        fullVec(block.InputPort(2).Data(:)+1);
                                                    end
                                                else
                                                    for j=1:ncol
                                                        fullVec=20*log10(abs(fft(block.Dwork(j+1).Data,N))/N)+30;
                                                        block.OutputPort(1).Data(:,j)=...
                                                        fullVec(block.InputPort(2).Data(:,j)+1);
                                                    end
                                                end
                                            end
                                        end


