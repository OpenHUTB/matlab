// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ReflectExtensions.java

package org.eclipse.xtext.xbase.lib.util;

import com.google.common.base.Preconditions;
import java.lang.reflect.*;

public class ReflectExtensions
{

    public ReflectExtensions()
    {
    }

    public void set(Object receiver, String fieldName, Object value)
        throws SecurityException, NoSuchFieldException, IllegalArgumentException, IllegalAccessException
    {
        Preconditions.checkNotNull(receiver, "receiver");
        Preconditions.checkNotNull(fieldName, "fieldName");
        Class clazz = receiver.getClass();
        Field f = getDeclaredField(clazz, fieldName);
        if(!f.isAccessible())
            f.setAccessible(true);
        f.set(receiver, value);
    }

    public Object get(Object receiver, String fieldName)
        throws SecurityException, NoSuchFieldException, IllegalArgumentException, IllegalAccessException
    {
        Preconditions.checkNotNull(receiver, "receiver");
        Preconditions.checkNotNull(fieldName, "fieldName");
        Class clazz = receiver.getClass();
        Field f = getDeclaredField(clazz, fieldName);
        if(!f.isAccessible())
            f.setAccessible(true);
        return f.get(receiver);
    }

    private Field getDeclaredField(Class clazz, String name)
        throws NoSuchFieldException
    {
        NoSuchFieldException initialException = null;
        do
            try
            {
                Field f = clazz.getDeclaredField(name);
                return f;
            }
            catch(NoSuchFieldException noSuchField)
            {
                if(initialException == null)
                    initialException = noSuchField;
            }
        while((clazz = clazz.getSuperclass()) != null);
        throw initialException;
    }

    public transient Object invoke(Object receiver, String methodName, Object args[])
        throws SecurityException, IllegalArgumentException, IllegalAccessException, InvocationTargetException, NoSuchMethodException
    {
        Preconditions.checkNotNull(receiver, "receiver");
        Preconditions.checkNotNull(methodName, "methodName");
        Object arguments[] = args != null ? args : (new Object[] {
            null
        });
        Class clazz = receiver.getClass();
        Method compatible = null;
        do
        {
            Method amethod[] = clazz.getDeclaredMethods();
            int j = amethod.length;
            for(int k = 0; k < j; k++)
            {
                Method candidate = amethod[k];
                if(candidate == null || candidate.isBridge() || !isCompatible(candidate, methodName, arguments))
                    continue;
                if(compatible != null)
                    throw new IllegalStateException((new StringBuilder()).append("Ambiguous methods to invoke. Both ").append(compatible).append(" and  ").append(candidate).append(" would be compatible choices.").toString());
                compatible = candidate;
            }

        } while(compatible == null && (clazz = clazz.getSuperclass()) != null);
        if(compatible != null)
        {
            if(!compatible.isAccessible())
                compatible.setAccessible(true);
            return compatible.invoke(receiver, arguments);
        }
        Class paramTypes[] = new Class[arguments.length];
        for(int i = 0; i < arguments.length; i++)
            paramTypes[i] = ((Class) (arguments[i] != null ? arguments[i].getClass() : java/lang/Object));

        Method method = receiver.getClass().getMethod(methodName, paramTypes);
        return method.invoke(receiver, arguments);
    }

    private transient boolean isCompatible(Method candidate, String featureName, Object args[])
    {
        if(!candidate.getName().equals(featureName))
            return false;
        if(candidate.getParameterTypes().length != args.length)
            return false;
        for(int i = 0; i < candidate.getParameterTypes().length; i++)
        {
            Object param = args[i];
            Class class1 = candidate.getParameterTypes()[i];
            if(class1.isPrimitive())
                class1 = wrapperTypeFor(class1);
            if(param != null && !class1.isInstance(param))
                return false;
        }

        return true;
    }

    private Class wrapperTypeFor(Class primitive)
    {
        Preconditions.checkNotNull(primitive);
        if(primitive == Boolean.TYPE)
            return java/lang/Boolean;
        if(primitive == Byte.TYPE)
            return java/lang/Byte;
        if(primitive == Character.TYPE)
            return java/lang/Character;
        if(primitive == Short.TYPE)
            return java/lang/Short;
        if(primitive == Integer.TYPE)
            return java/lang/Integer;
        if(primitive == Long.TYPE)
            return java/lang/Long;
        if(primitive == Float.TYPE)
            return java/lang/Float;
        if(primitive == Double.TYPE)
            return java/lang/Double;
        if(primitive == Void.TYPE)
            return java/lang/Void;
        else
            throw new IllegalArgumentException((new StringBuilder()).append(primitive).append(" is not a primitive").toString());
    }
}
