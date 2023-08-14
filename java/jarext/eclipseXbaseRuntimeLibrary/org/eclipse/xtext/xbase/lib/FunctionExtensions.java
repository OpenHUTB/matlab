// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FunctionExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Functions, Procedures

public class FunctionExtensions
{

    public FunctionExtensions()
    {
    }

    public static Functions.Function0 curry(Functions.Function1 function, Object argument)
    {
        if(function == null)
            throw new NullPointerException("function");
        else
            return new Functions.Function0(function, argument) {

                public Object apply()
                {
                    return function.apply(argument);
                }

                final Functions.Function1 val$function;
                final Object val$argument;

            
            {
                function = function1;
                argument = obj;
                super();
            }
            }
;
    }

    public static Functions.Function1 curry(Functions.Function2 function, Object argument)
    {
        if(function == null)
            throw new NullPointerException("function");
        else
            return new Functions.Function1(function, argument) {

                public Object apply(Object p)
                {
                    return function.apply(argument, p);
                }

                final Functions.Function2 val$function;
                final Object val$argument;

            
            {
                function = function2;
                argument = obj;
                super();
            }
            }
;
    }

    public static Functions.Function2 curry(Functions.Function3 function, Object argument)
    {
        if(function == null)
            throw new NullPointerException("function");
        else
            return new Functions.Function2(function, argument) {

                public Object apply(Object p2, Object p3)
                {
                    return function.apply(argument, p2, p3);
                }

                final Functions.Function3 val$function;
                final Object val$argument;

            
            {
                function = function3;
                argument = obj;
                super();
            }
            }
;
    }

    public static Functions.Function3 curry(Functions.Function4 function, Object argument)
    {
        if(function == null)
            throw new NullPointerException("function");
        else
            return new Functions.Function3(function, argument) {

                public Object apply(Object p2, Object p3, Object p4)
                {
                    return function.apply(argument, p2, p3, p4);
                }

                final Functions.Function4 val$function;
                final Object val$argument;

            
            {
                function = function4;
                argument = obj;
                super();
            }
            }
;
    }

    public static Functions.Function4 curry(Functions.Function5 function, Object argument)
    {
        if(function == null)
            throw new NullPointerException("function");
        else
            return new Functions.Function4(function, argument) {

                public Object apply(Object p2, Object p3, Object p4, Object p5)
                {
                    return function.apply(argument, p2, p3, p4, p5);
                }

                final Functions.Function5 val$function;
                final Object val$argument;

            
            {
                function = function5;
                argument = obj;
                super();
            }
            }
;
    }

    public static Functions.Function5 curry(Functions.Function6 function, Object argument)
    {
        if(function == null)
            throw new NullPointerException("function");
        else
            return new Functions.Function5(function, argument) {

                public Object apply(Object p2, Object p3, Object p4, Object p5, Object p6)
                {
                    return function.apply(argument, p2, p3, p4, p5, p6);
                }

                final Functions.Function6 val$function;
                final Object val$argument;

            
            {
                function = function6;
                argument = obj;
                super();
            }
            }
;
    }

    public static Functions.Function1 compose(Functions.Function1 after, Functions.Function1 before)
    {
        if(after == null)
            throw new NullPointerException("after");
        if(before == null)
            throw new NullPointerException("before");
        else
            return new Functions.Function1(after, before) {

                public Object apply(Object v)
                {
                    return after.apply(before.apply(v));
                }

                final Functions.Function1 val$after;
                final Functions.Function1 val$before;

            
            {
                after = function1;
                before = function1_1;
                super();
            }
            }
;
    }

    public static Functions.Function1 andThen(Functions.Function1 before, Functions.Function1 after)
    {
        return compose(after, before);
    }

    public static Functions.Function2 andThen(Functions.Function2 before, Functions.Function1 after)
    {
        if(after == null)
            throw new NullPointerException("after");
        if(before == null)
            throw new NullPointerException("before");
        else
            return new Functions.Function2(after, before) {

                public Object apply(Object v1, Object v2)
                {
                    return after.apply(before.apply(v1, v2));
                }

                final Functions.Function1 val$after;
                final Functions.Function2 val$before;

            
            {
                after = function1;
                before = function2;
                super();
            }
            }
;
    }

    public static Procedures.Procedure1 andThen(Procedures.Procedure1 before, Procedures.Procedure1 after)
    {
        if(after == null)
            throw new NullPointerException("after");
        if(before == null)
            throw new NullPointerException("before");
        else
            return new Procedures.Procedure1(before, after) {

                public void apply(Object p)
                {
                    before.apply(p);
                    after.apply(p);
                }

                final Procedures.Procedure1 val$before;
                final Procedures.Procedure1 val$after;

            
            {
                before = procedure1;
                after = procedure1_1;
                super();
            }
            }
;
    }

    public static Procedures.Procedure0 andThen(Procedures.Procedure0 before, Procedures.Procedure0 after)
    {
        if(after == null)
            throw new NullPointerException("after");
        if(before == null)
            throw new NullPointerException("before");
        else
            return new Procedures.Procedure0(before, after) {

                public void apply()
                {
                    before.apply();
                    after.apply();
                }

                final Procedures.Procedure0 val$before;
                final Procedures.Procedure0 val$after;

            
            {
                before = procedure0;
                after = procedure0_1;
                super();
            }
            }
;
    }
}
