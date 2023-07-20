function result=addModel(this,rootName,reqFileName)







    if nargin>1

        if~ischar(rootName)

            rootH=rootName;
            if rmisl.isComponentHarness(rootH)
                [~,rootName]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(rootH);





                systemModelName=strtok(rootName,':');
                parentRoot=this.ensureRoot(systemModelName);
                harnessData.id=rootName;
                harnessData.handle=rootH;
                t0=M3I.Transaction(this.graph);
                this.updateHarnessNodeData(parentRoot,harnessData);
                t0.commit;
            else
                rootName=get_param(rootH,'Name');
            end
        end

        if nargin>2




            type=rmimap.validateReqFile(reqFileName);
            switch type
            case 'mdlGraph'
                myRoot=this.readGraph(reqFileName,rootName);
            case 'mdlRoot'
                myRoot=this.readRoot(reqFileName,rootName);
            otherwise
                error(message('Slvnv:rmigraph:InvalidReqFile',reqFileName));
            end
        else


            t1=M3I.Transaction(this.graph);
            myRoot=rmidd.Root(this.graph);
            this.graph.roots.append(myRoot);
            myRoot.url=rootName;


            myRoot.setProperty('source','linktype_rmi_simulink');

            t1.commit;
        end

    else

        warning(message('Slvnv:rmigraph:BadUsage'));
        t1=M3I.Transaction(this.graph);
        myRoot=rmidd.Root(this.graph);
        this.graph.append(myRoot);
        myRoot.url='untitled';


        myRoot.setProperty('source','linktype_rmi_simulink');

        t1.commit;
    end

    result=myRoot;
end


