function simrfV2_msfcn_arrange_sparam(block)




    setup(block);



    function setup(block)


        block.NumInputPorts=1;
        block.NumOutputPorts=1;
        block.NumDialogPrms=3;



        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;

        block.InputPort(1).DirectFeedthrough=true;
        block.InputPort(1).SampleTime=[-1,0];
        block.InputPort(1).Complexity='Complex';
        block.OutputPort(1).SampleTime=[-1,0];
        block.OutputPort(1).Complexity='Complex';



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
                SParamElem2Len=length(block.DialogPrm(3).Data);
                block.InputPort(1).SampleTime=st;
                block.OutputPort(1).SampleTime=[st(1)*SParamElem2Len,st(2)];
            end



            function SetOutPortST(block,~,st)
                if st<=0
                    error('This block only supports discrete sample time')
                else
                    SParamElem2Len=length(block.DialogPrm(3).Data);
                    block.OutputPort(1).SampleTime=st;
                    block.InputPort(1).SampleTime=[st(1)/SParamElem2Len,st(2)];
                end



                function SetInpPortDims(block,port,di)
                    SParamElem1IndLen=length(block.DialogPrm(2).Data);
                    SParamElem1Selncol=size(block.DialogPrm(1).Data,2);
                    block.InputPort(port).Dimensions=di;
                    if~isempty(block.InputPort(1).Dimensions)
                        di_p=block.InputPort(1).Dimensions;
                        if(length(di_p)==2)&&(di_p(1)==1)
                            if mod(di_p(2),SParamElem1Selncol)==0
                                block.OutputPort(1).Dimensions=[SParamElem1IndLen...
                                ,floor(di_p(2)/SParamElem1Selncol)];
                            else
                                error(['Input length must divisable by the number of '...
                                ,'columns of S-parameter output values']);
                            end
                        else
                            error('Input size must be [1xN]');
                        end
                    end




                    function SetOutPortDims(block,~,di)
                        SParamElem1IndLen=length(block.DialogPrm(2).Data);
                        SParamElem1Selncol=size(block.DialogPrm(1).Data,2);
                        if~isempty(block.OutputPort(1).Dimensions)

                            if length(di)==2
                                if di(1)==SParamElem1IndLen
                                    block.InputPort(1).Dimensions=[1,SParamElem1Selncol*di(2)];
                                    block.OutputPort(1).Dimensions=di;
                                else
                                    error(['Output size should be [MxN], with M equal to the '...
                                    ,'length of S-parameter output indices']);
                                end
                            else
                                error('Output size must be [MxN]');
                            end
                        end



                        function DoPostPropSetup(block)


                            ncol=max(block.InputPort(1).Dimensions);
                            SParamElem2Len=length(block.DialogPrm(3).Data);


                            block.NumDworks=SParamElem2Len+1;
                            block.Dwork(1).Name='index';
                            block.Dwork(1).Dimensions=1;
                            block.Dwork(1).DatatypeID=0;
                            block.Dwork(1).Complexity='Real';
                            block.Dwork(1).UsedAsDiscState=true;


                            for i=(1:SParamElem2Len)+1
                                block.Dwork(i).Name=['y',num2str(i-2)];
                                block.Dwork(i).Dimensions=ncol;
                                block.Dwork(i).DatatypeID=0;
                                block.Dwork(i).Complexity='Complex';
                                block.Dwork(i).UsedAsDiscState=true;
                            end


                            function InitConditions(block)






                                block.Dwork(1).Data=block.NumDworks-2;
                                for colIdx=2:block.NumDworks


                                    block.Dwork(colIdx).Data(:)=complex(realmin,realmin);
                                end



                                function Update(block)

                                    if block.InputPort(1).IsSampleHit
                                        bufferIndex=block.Dwork(1).Data+1;
                                        block.Dwork(bufferIndex+1).Data(:)=block.InputPort(1).Data;
                                        if bufferIndex==block.NumDworks-1
                                            bufferIndex=0;
                                        end
                                        block.Dwork(1).Data=bufferIndex;
                                    end


                                    function Output(block)


                                        if block.InputPort(1).IsSampleHit
                                            if block.Dwork(1).Data==0
                                                SParamElem2Len=length(block.DialogPrm(3).Data);
                                                SParamElem1Selncol=size(block.DialogPrm(1).Data,2);
                                                SParamElem1Ind=block.DialogPrm(2).Data;
                                                mat=zeros(block.Dwork(2).Dimensions/SParamElem1Selncol,...
                                                SParamElem1Selncol*SParamElem2Len);
                                                for jInd=2:block.NumDworks
                                                    mat(:,(1:SParamElem1Selncol)+(jInd-2)*SParamElem1Selncol)=...
                                                    reshape(block.Dwork(jInd).Data,[],SParamElem1Selncol);
                                                end
                                                block.OutputPort(1).Data=permute(mat(:,SParamElem1Ind),[2,1]);
                                            end
                                        end


