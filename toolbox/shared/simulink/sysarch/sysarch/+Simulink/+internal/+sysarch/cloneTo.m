function dst=cloneTo(dstDataModel,src)

    dst=l_cloneTo(dstDataModel,src);

    function dst=l_cloneTo(dstDataModel,src)

        switch class(src)


        case 'SystemArchitecture.DataInterface'

            dst=cloneInterface(dstDataModel,src);

        case 'SystemArchitecture.DataElement'
            assert(false,'Not handled yet');

        otherwise
            assert(false,['Unhandled object type: ',class(src)]);
        end

        function intrf=cloneInterface(dataModel,refIntrf)

            dataModel.beginTransaction;

            intrf=SystemArchitecture.DataInterface(dataModel);
            intrf.Name=refIntrf.Name;
            intrf.Package=dataModel;


            assert(refIntrf.DataElement.size==0);

            dataModel.commitTransaction;
