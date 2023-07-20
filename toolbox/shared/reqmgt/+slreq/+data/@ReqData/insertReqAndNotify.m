function insertReqAndNotify(this,mfReqSet,mfParentReq,mfReq)











    reqInserted=false;

    if~isempty(mfParentReq)
        mfReq.parent=mfParentReq;
    else

        if mfReqSet.rootItems.Size>0

            lastObj=mfReqSet.rootItems.at(mfReqSet.rootItems.Size);
            if isa(lastObj,'slreq.datamodel.Justification')



                mfReqSet.rootItems.add(mfReq);
                this.moveRequirement(mfReq,'before',lastObj);
                reqInserted=true;
            else


                mfReqSet.rootItems.add(mfReq);
            end
        else

            mfReqSet.rootItems.add(mfReq);
        end
    end

    if this.isNotifying
        dataReq=this.wrap(mfReq);


        if~reqInserted

            this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Added',dataReq));
        else


            this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement AddedAfter',dataReq));
        end
    end
end