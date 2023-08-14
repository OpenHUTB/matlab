classdef RegTableDDG<handle








    properties(Access=private)
blkH
blkP
tabP
numRegs
pmap
cmap
dmap
    end
    properties(Constant)
        NUM_COLS=4;
    end
    methods
        function obj=RegTableDDG(blkH)
            obj.pmap=containers.Map((1:obj.NUM_COLS),{'RegTableNames','RegTableVectorLengths','RegTableOffsets','RegTableDefaultValues'});
            obj.cmap=containers.Map((1:obj.NUM_COLS),{'Register Name','Vector Length','Address Offset','Default Value'});
            obj.dmap=containers.Map((1:obj.NUM_COLS),{'reg','1','x"0000"','x"0000"'});

            obj.blkH=blkH;
            obj.blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
            obj.tabP=obj.getTableParams();
            obj.numRegs=obj.reconcileNumRegs();
        end

        function numRegs=reconcileNumRegs(obj)
            wantTableRegs=obj.blkP.NumRegisters;
            currTableRegs=numel(obj.tabP.(obj.pmap(1)));
            if(wantTableRegs<currTableRegs)
                warning('number of rows is being reduced');
                for c=1:obj.NUM_COLS
                    fn=obj.pmap(c);
                    obj.tabP.(fn)={obj.tabP.(fn){1:wantTableRegs}};
                end
            elseif(wantTableRegs>currTableRegs)
                for c=1:obj.NUM_COLS
                    fn=obj.pmap(c);
                    for padrow=currTableRegs+1:wantTableRegs
                        switch fn
                        case 'RegTableNames'
                            obj.tabP.(fn){padrow}=[obj.dmap(c),num2str(padrow)];
                        otherwise
                            obj.tabP.(fn){padrow}=obj.dmap(c);
                        end
                    end
                end
            end
            numRegs=wantTableRegs;
        end

        function dlg=getDialogSchema(obj,~)

            tdata=cell(obj.numRegs,obj.NUM_COLS);
            for r=1:obj.numRegs
                regdefval.Type='edit';
                regdefval.Enabled=false;
                regdefval.Value=obj.tabP.(obj.pmap(4)){r};

                tdata{r,1}=obj.tabP.(obj.pmap(1)){r};
                tdata{r,2}=obj.tabP.(obj.pmap(2)){r};
                tdata{r,3}=obj.tabP.(obj.pmap(3)){r};
                tdata{r,4}=regdefval;
            end
            t.Name='Register Table';
            t.Type='table';
            t.Tag='regtable';
            t.ColHeader=values(obj.cmap);
            t.Size=size(tdata);


            t.RowHeaderWidth=0;
            t.Editable=true;
            t.Data=tdata;

            dlg.DialogTitle='Edit Register Bank';
            dlg.Items={t};
            dlg.Sticky=true;



            dlg.PreApplyMethod='preApplyCb';
            dlg.PreApplyArgs={'%dialog'};
            dlg.PreApplyArgsDT={'handle'};
            dlg.PostApplyMethod='postApplyCb';
            dlg.PostApplyArgs={'%dialog'};
            dlg.PostApplyArgsDT={'handle'};
        end

        function preApplyCb(obj,dlg)

            for cidx=1:obj.NUM_COLS
                fn=obj.pmap(cidx);
                for ridx=1:obj.numRegs

                    strval=dlg.getTableItemValue('regtable',ridx-1,cidx-1);
                    switch fn
                    case 'RegTableVectorLengths'
                        val1=eval(strval);
                        if~isscalar(val1)
                            error(message('soc:msgs:RegTableVecLengthScalar'));
                        end
                    otherwise
                    end
                    obj.tabP.(fn){ridx}=strval;
                end
            end
        end
        function postApplyCb(obj,~)

            obj.setTableParams();
        end
...
...
...
...
...
...
...
...
...
...

        function tp=getTableParams(obj)
            for idx=1:obj.NUM_COLS
                fn=obj.pmap(idx);
                tp.(fn)=obj.blkP.(fn);
            end
        end
        function setTableParams(obj)
            for idx=1:obj.NUM_COLS
                fn=obj.pmap(idx);
                val1=obj.tabP.(fn);
                val2=['{',sprintf('''%s'' ',val1{:}),'}'];
                set_param(obj.blkH,fn,val2);
            end
        end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    end
end


