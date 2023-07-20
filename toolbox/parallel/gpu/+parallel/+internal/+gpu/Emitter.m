classdef Emitter








    methods(Static=true,Hidden=true)





        function hex=makehexnumber(type,numeric)

            assert(isScalar(type),'emitter:makehexnumber','only scalars can be converted to literals');

            if isDouble(type)
                hex=sprintf('0d%bx',numeric);
            elseif isSingle(type)
                hex=sprintf('0f%tx',numeric);
            elseif isInteger(type)||isLogical(type)
                hex=sprintf('%d',numeric);
            else

                assert(false,'Making machine representation of non-numeric type: ''%s''.',mType(type));
            end

        end

    end


    methods(Abstract=true,Hidden=true)





        interruptible=supportsInterrupt(obj)




        instr=branchToEpilogue(obj)

        instr=branchToLabel(obj,label)

        instr=conditionalBranchToLabel(obj,branchreg,label)

        instr=arraySizeCheck(obj,internalState,sizeVariable,gtid)


        instr=unacall(obj,internalState,typeOut,outregReal,outregImag,fn,regReal,regImag)


        instr=bincall(obj,internalState,typeOut,outregReal,outregImag,fn,regReal1,regImag1,regReal2,regImag2)


        instr=ternarycall(obj,internalState,typeOut,outregReal,outregImag,fn,regReal1,regImag1,regReal2,regImag2,regReal3,regImag3)


        instr=fetchArrayElementLinearIndexing(obj,internalState,outregReal,outregImag,type,ptrdata,ptrshape,typeIndex,linearIndex)


        instr=fetchArrayElementCoordinateIndexing(obj,internalState,outregReal,outregImag,type,ptrdata,ptrshape,coordinateTypes,coordinateIndices,numOfDims)


        instr=loadSymbol(obj,internalState,symbols,name,rdb)

        instr=loadSymbols(obj,internalState,symbols,names,expansionkey,rdb,gtid)

        instr=loadImplicitSymbols(obj,internalState,fcnLabel,iR)

        instr=storeSymbol(obj,internalState,symbols,name,rdb)

        instr=storeSymbols(obj,internalState,symbols,fcnName,iR,rdb)


        instr=makePrologue(obj,internalState,entry,computeGtid)

        instr=beginEpilogue(obj)

        instr=endEpilogue(obj)


        instr=declareRegisters(obj,internalState)


        instr=moduleHeader(obj,internalState)


        [PFS,cproto,types,complexities,entryname,entry]=mangleCprotoEntry(obj,internalState,symbols,fcnLabel,iR,expansionkey)






        [instr,typeOut,outreg]=logicalInstruction(obj,internalState,operation,typeIn1,reg1,typeIn2,reg2)


        [instr,typeOut,outreg]=relopInstruction(obj,internalState,operation,typeIn,regReal1,regImag1,regin2,regImag2)


        [instr,outreg]=bitshiftInstruction(obj,internalState,reg1,typeIn2,reg2)


        instr=arithmeticInstruction(obj,internalState,operation,type,outregReal,outregImag,regReal1,regImag1,regReal2,regImag2)

        instr=saturatedIntegerAddition(obj,internalState,type,outreg,intreg1,intreg2)

        instr=saturatedIntegerSubtraction(obj,internalState,type,outreg,intreg1,intreg2)

        instr=saturatedIntegerMultiplication(obj,internalState,type,outreg,intreg1,intreg2)

        instr=saturatedIntegerDivision(obj,type,internalState,outreg,intreg1,intreg2)


        instr=logicalSCInstruction(obj,internalState,operation,outreg,reg,endlabel)


        [instr,ro,ro2]=sampleRandAndAdvance(obj,internalState,fn,type,varargin)





        [instr,outregReal,outregImag]=constant(obj,internalState,type,scon)

        [instr,outregReal,outregImag]=loadrealminmax(obj,internalState,type,fn)



        [instr,outregReal,outregImag]=copyreg(obj,internalState,typeOut,regReal,regImag)


        [instr,varargout]=castregisters(obj,internalState,varargin)


        [instr,outregReal,outregImag]=castreg(obj,internalState,typeOut,typeIn,regReal,regImag)


        [instr,outregReal,outregImag]=movereg(obj,internalState,typeOut,outregReal,outregImag,regReal,regImag)



        [instr,outreg]=negatereg(obj,internalState,type,reg)


        [instr,typeOut,outreg]=logicalnotreg(obj,internalState,typeIn,reg)


        instr=absreg(obj,typeOut,outreg,reg)


        instr=fixreg(obj,typeOut,outreg,reg)


        instr=ceilfloorreg(obj,typeOut,outreg,reg,fn)


        instr=xorreg(obj,outreg,reg1,reg2)


        instr=bitcmpreg(obj,outreg,reg)


        instr=bitopreg(obj,operation,outreg,regReal,regImag)


        [instr,outregReal]=zerohigherbits(obj,internalState,type,regReal)


        instr=setpredicatereg(obj,operation,branchreg,typeIn,reg1,reg2)




        instr=updateShadowCounter(obj,typeShadow,regShadowCounter,regShadow,regBegin,regStep)

        [instr,regResult]=loopLength(obj,internalState,typeIndex,regBegin,regStep,regLast,typeShadow,endlabel)


    end


end

