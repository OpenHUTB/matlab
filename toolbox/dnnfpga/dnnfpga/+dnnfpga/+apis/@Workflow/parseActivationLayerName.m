function[acts_idx,acts_lname,acts_output]=parseActivationLayerName(net,activationLayer)






    if strcmp(activationLayer,"InputToFPGA")
        acts_idx=1;
        acts_lname=activationLayer;
        acts_output='out';
        return
    end


    if isa(net,'SeriesNetwork')


        acts_lname=activationLayer;
        acts_output=[];
    elseif(isa(net,'DAGNetwork')||isa(net,'dlnetwork'))


        [acts_lname,acts_output]=parseLayerNameForDAGNet(activationLayer);
    else

    end


    layers=net.Layers;
    acts_idx=validateLayerName(layers,acts_lname);


    actLayer=net.Layers(acts_idx);
    acts_output=validateOutput(actLayer,acts_output);

end

function[acts_lname,acts_output]=parseLayerNameForDAGNet(activationLayer)





    actParts=strsplit(activationLayer,'/');
    if numel(actParts)==1
        acts_lname=actParts{1};
        acts_output=[];
    elseif numel(actParts)==2
        acts_lname=actParts{1};
        acts_output=actParts{2};
    else
        error(message('dnnfpga:workflow:ActivationsMultipleSlash'));
    end
end

function acts_idx=validateLayerName(layers,acts_lname)
    if strcmp('InputToFPGA',acts_lname)
        acts_idx=1;
        return;
    else
        for i=1:length(layers)
            if strcmp(layers(i).Name,acts_lname)
                acts_idx=i;
                return;
            end
        end
    end

    error(message('dnnfpga:workflow:InvalidActivationLayer',acts_lname));
end

function acts_output=validateOutput(actLayer,acts_output)









    validOutputs=actLayer.OutputNames;
    numValOuts=numel(validOutputs);

    if isempty(acts_output)

        if numValOuts==0

            acts_output='out';
        elseif numValOuts==1

            acts_output=validOutputs{1};
        elseif numValOuts>1

            error(message('dnnfpga:workflow:ActivationsOutputUnderspecified',actLayer.Name))
        end
    else

        if numValOuts==0

            error(message('dnnfpga:workflow:ActivationsNonExistantOutput',actLayer.Name,acts_output))
        elseif numValOuts>0
            isValid=false;
            for i=1:numValOuts
                if strcmp(acts_output,validOutputs{i})
                    isValid=true;
                    break
                end
            end
            if~isValid

                error(message('dnnfpga:workflow:ActivationsNonExistantOutput',actLayer.Name,acts_output))
            else
                if isa(actLayer,'nnet.cnn.layer.MaxPooling2DLayer')&&~strcmp(acts_output,'out')

                    error(message('dnnfpga:workflow:ActivationUnsupportedOutput',acts_output,actLayer.Name));
                else


                end
            end
        end
    end

end


