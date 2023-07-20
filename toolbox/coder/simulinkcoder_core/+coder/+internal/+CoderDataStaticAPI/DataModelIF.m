classdef(Abstract)DataModelIF<handle



    methods(Static)

        setProp(entry,name,value)
        setEnumProp(entry,name,value)
        setComponentInstanceProp(entry,type,name,value)
        out=getProp(entry,name)


        ret=createEntry(dd,type,name,varargin)
        out=cloneEntry(dd,type,origName,newName)
        deleteEntry(dd,type,name)
        deleteAll(dd)



        out=getClassName(entry)


        out=getCoderData(dd,type)
        ret=getDDSection(dd,type)
        out=findEntry(dd,type,name);


        [dd,fPath]=openDD(dd)
        out=isOpen(dd)


        out=hasSWCT(dd)
        moveSCToSWCT(dd,scEntries)
        moveMSToSWCT(swc,scEntries)
        swc=createSWCT(dd)


        addAllowableCoderDataForElement(swcEntry,category,msEntry)
        setAllowableCoderDataForElement(swc,modelElementType,coderDataType,entries)
        out=getAllowableCoderDataForElement(swc,category)


        out=beginTxn(dd)
        commitTxn(txn)
        rollbackTxn(txn)
    end

end



