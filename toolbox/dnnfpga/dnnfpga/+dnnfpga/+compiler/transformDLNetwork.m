function[transformedNet]=transformDLNetwork(net,verbose)








    lgraph=layerGraph(net);






    sourcesList=lgraph.Connections.Source;
    index=1;
    for p=1:numel(net.Layers)
        if(~any(strcmp(sourcesList,net.Layers(p).Name)))
            newname=strcat('Output',num2str(index),'_',net.Layers(p).Name);
            outLayer=regressionLayer(n=newname);
            lgraph=addLayers(lgraph,outLayer);
            lgraph=connectLayers(lgraph,lgraph.Layers(p).Name,outLayer.Name);
            index=index+1;

            msg=message('dnnfpga:dnnfpgacompiler:DLNetOutputAdded',newname,class(outLayer));
            dnnfpga.disp(msg,1,verbose);
        end
    end

    transformedNet=assembleNetwork(lgraph);

end