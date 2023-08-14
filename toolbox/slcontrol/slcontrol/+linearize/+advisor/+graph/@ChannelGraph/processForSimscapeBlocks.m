function this=processForSimscapeBlocks(this)






















    handles=unique([this.Nodes.JacobianBlockHandle]');

    inputhandles=handles(linearize.advisor.utils.isSimscapeInputBlock(handles));

    outputhandles=handles(linearize.advisor.utils.isSimscapeOutputBlock(handles));

    statehandles=handles(linearize.advisor.utils.isSimscapeStateBlock(handles));

    for blkh=inputhandles(:)'
        this=LocalRemoveDisconnectedBlockStates(this,blkh);
        this=LocalRemoveUnreachableBlockChannels(this,blkh);
    end
    for blkh=outputhandles(:)'
        this=LocalRemoveUnreachableBlockChannels(this,blkh);
    end
    for blkh=statehandles(:)'
        this=LocalProcessStateBlocks(this,blkh);
    end

    function this=LocalProcessStateBlocks(this,blkh)


        import linearize.advisor.graph.*
        handles=[this.Nodes.JacobianBlockHandle]';
        types=[this.Nodes.Type]';
        yidx=handles==blkh&types==NodeTypeEnum.OUTCHANNEL;
        uidx=handles==blkh&types==NodeTypeEnum.INCHANNEL;
        iotypes=(types==NodeTypeEnum.INLINIO)|(types==NodeTypeEnum.OUTLINIO);
        nosuc=all(~this.Adj,1);
        nopred=all(~this.Adj,2);
        rmIdx=(yidx&nosuc(:))|(uidx&nopred)&~iotypes;
        this=rmNodes(this,rmIdx);

        function this=LocalRemoveDisconnectedBlockStates(this,blkh)

            import linearize.advisor.graph.*
            handles=[this.Nodes.JacobianBlockHandle]';
            types=[this.Nodes.Type]';
            sIdx=handles==blkh&types==NodeTypeEnum.INCHANNEL;
            tIdx=handles==blkh&types==NodeTypeEnum.OUTCHANNEL;
            xIdx=handles==blkh&types==NodeTypeEnum.STATE;
            rIdx=getReachableNodesFromSrc2Snk(this,sIdx,tIdx);
            rmIdx=~rIdx&xIdx;
            this=rmNodes(this,rmIdx);

            function this=LocalRemoveUnreachableBlockChannels(this,blkh)
                import linearize.advisor.graph.*
                handles=[this.Nodes.JacobianBlockHandle]';
                types=[this.Nodes.Type]';
                sIdx=handles==blkh&types==NodeTypeEnum.INCHANNEL;
                tIdx=handles==blkh&types==NodeTypeEnum.OUTCHANNEL;
                iotypes=(types==NodeTypeEnum.INLINIO)|(types==NodeTypeEnum.OUTLINIO);

                opred=predecessors(this,types==NodeTypeEnum.OUTLINIO);
                rIdx=getReachableNodesFromSrc2Snk(this,sIdx,tIdx);
                rmIdx=~rIdx&(sIdx|tIdx)&~iotypes&~opred;
                this=rmNodes(this,rmIdx);