function schema()






    hCreateInPackage=findpackage('RTWConfiguration');


    hThisClass=schema.class(hCreateInPackage,'Node');




    schema.prop(hThisClass,'key','string');


    hThisProp=schema.prop(hThisClass,'data','handle');
    hThisProp.setFunction=@setData;


    hThisProp=schema.prop(hThisClass,'resources','handle');
    hThisProp.setFunction=@setResources;


    hThisProp=schema.prop(hThisClass,'right','handle');
    hThisProp.getFunction=@getRight;


    schema.prop(hThisClass,'classkey','string');


    schema.prop(hThisClass,'sourceLibrary','string');


    function data=setData(node,data)
        assert(isa(data,'RTWConfiguration.Data'));
        node.classkey=class(data);
        if~isempty(node.data)
            node.data.disconnect;
        end
        i_connect(node,data);


        function resources=setResources(node,resources)
            assert(isa(resources,'RTWConfiguration.ResourceHead'));
            if~isempty(node.resources)
                node.resources.disconnect;
            end
            i_connect(node,resources);


            function right=getRight(obj,~)
                right=feval('right',obj);
                if isempty(right)
                    right=RTWConfiguration.Terminator;
                end



                function i_connect(node,child)
                    if isempty(child.up)







                        listHead=node.up;

                        assert(isa(listHead,'RTWConfiguration.ListHead'),'Node must correctly connected');
                        target=listHead.up;
                        if~isempty(target)
                            target.connect(child,'down');
                            if target.activeList==listHead&&isa(child,'RTWConfiguration.Data')


                                child.activate(node,target);
                            end
                        else

                        end
                    end

