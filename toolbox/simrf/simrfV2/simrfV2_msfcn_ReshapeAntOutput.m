function simrfV2_msfcn_ReshapeAntOutput(block)






    setup(block);



    function setup(block)


        block.NumInputPorts=1;
        block.NumOutputPorts=1;
        block.NumDialogPrms=2;
        block.AllowSignalsWithMoreThan2D=1;



        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;

        block.InputPort(1).DirectFeedthrough=true;
        block.InputPort(1).DatatypeID=0;
        block.InputPort(1).Complexity='Inherited';
        block.OutputPort(1).Complexity='Inherited';



        block.SimStateCompliance='DefaultSimState';


        block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);
        block.RegBlockMethod('SetOutputPortDimensions',@SetOutPortDims);
        block.RegBlockMethod('Outputs',@Output);




        function SetInpPortDims(block,~,di)

            AntType=block.DialogPrm(2).Data;
            NumFreqs=block.DialogPrm(1).Data;
            thirdDim=AntType;
            if di(1)==NumFreqs
                firstDim=di(1)/thirdDim;
                secondDim=1;
            else
                firstDim=di(1)/NumFreqs/thirdDim;
                secondDim=NumFreqs;
            end
            block.InputPort(1).Dimensions=di;
            if thirdDim==1
                block.OutputPort(1).Dimensions=[firstDim,secondDim];
            else
                block.OutputPort(1).Dimensions=[firstDim,secondDim,thirdDim];
            end




            function SetOutPortDims(block,~,di)

                block.InputPort(1).Dimensions=[prod(di),1];
                block.OutputPort(1).Dimensions=di;



                function Output(block)

                    block.OutputPort(1).Data=reshape(block.InputPort(1).Data,block.OutputPort(1).Dimensions);



