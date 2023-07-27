// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Conversions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.collect.Iterables;
import com.google.common.primitives.*;
import java.lang.reflect.Array;
import java.util.*;

// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            IterableExtensions

public final class Conversions
{
    public static final class WrappedBooleanArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedBooleanArray create(boolean array[])
        {
            return new WrappedBooleanArray(array);
        }

        public Boolean get(int index)
        {
            return Boolean.valueOf(array[index]);
        }

        public Boolean set(int index, Boolean element)
        {
            modCount++;
            boolean old = array[index];
            array[index] = element.booleanValue();
            return Boolean.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Boolean)
                return Booleans.indexOf(array, ((Boolean)o).booleanValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Boolean)
                return Booleans.lastIndexOf(array, ((Boolean)o).booleanValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Boolean)
                return Booleans.contains(array, ((Boolean)o).booleanValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public boolean[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Boolean)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final boolean array[];

        protected WrappedBooleanArray(boolean array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedCharacterArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedCharacterArray create(char array[])
        {
            return new WrappedCharacterArray(array);
        }

        public Character get(int index)
        {
            return Character.valueOf(array[index]);
        }

        public Character set(int index, Character element)
        {
            modCount++;
            char old = array[index];
            array[index] = element.charValue();
            return Character.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Character)
                return Chars.indexOf(array, ((Character)o).charValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Character)
                return Chars.lastIndexOf(array, ((Character)o).charValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Character)
                return Chars.contains(array, ((Character)o).charValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public char[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Character)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final char array[];

        protected WrappedCharacterArray(char array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedDoubleArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedDoubleArray create(double array[])
        {
            return new WrappedDoubleArray(array);
        }

        public Double get(int index)
        {
            return Double.valueOf(array[index]);
        }

        public Double set(int index, Double element)
        {
            modCount++;
            double old = array[index];
            array[index] = element.doubleValue();
            return Double.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Double)
                return Doubles.indexOf(array, ((Double)o).doubleValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Double)
                return Doubles.lastIndexOf(array, ((Double)o).doubleValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Double)
                return Doubles.contains(array, ((Double)o).doubleValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public double[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Double)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final double array[];

        protected WrappedDoubleArray(double array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedFloatArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedFloatArray create(float array[])
        {
            return new WrappedFloatArray(array);
        }

        public Float get(int index)
        {
            return Float.valueOf(array[index]);
        }

        public Float set(int index, Float element)
        {
            modCount++;
            float old = array[index];
            array[index] = element.floatValue();
            return Float.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Float)
                return Floats.indexOf(array, ((Float)o).floatValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Float)
                return Floats.lastIndexOf(array, ((Float)o).floatValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Float)
                return Floats.contains(array, ((Float)o).floatValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public float[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Float)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final float array[];

        protected WrappedFloatArray(float array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedLongArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedLongArray create(long array[])
        {
            return new WrappedLongArray(array);
        }

        public Long get(int index)
        {
            return Long.valueOf(array[index]);
        }

        public Long set(int index, Long element)
        {
            modCount++;
            long old = array[index];
            array[index] = element.longValue();
            return Long.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Long)
                return Longs.indexOf(array, ((Long)o).longValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Long)
                return Longs.lastIndexOf(array, ((Long)o).longValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Long)
                return Longs.contains(array, ((Long)o).longValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public long[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Long)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final long array[];

        protected WrappedLongArray(long array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedIntegerArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedIntegerArray create(int array[])
        {
            return new WrappedIntegerArray(array);
        }

        public Integer get(int index)
        {
            return Integer.valueOf(array[index]);
        }

        public Integer set(int index, Integer element)
        {
            modCount++;
            int old = array[index];
            array[index] = element.intValue();
            return Integer.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Integer)
                return Ints.indexOf(array, ((Integer)o).intValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Integer)
                return Ints.lastIndexOf(array, ((Integer)o).intValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Integer)
                return Ints.contains(array, ((Integer)o).intValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public int[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Integer)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final int array[];

        protected WrappedIntegerArray(int array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedShortArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedShortArray create(short array[])
        {
            return new WrappedShortArray(array);
        }

        public Short get(int index)
        {
            return Short.valueOf(array[index]);
        }

        public Short set(int index, Short element)
        {
            modCount++;
            short old = array[index];
            array[index] = element.shortValue();
            return Short.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Short)
                return Shorts.indexOf(array, ((Short)o).shortValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Short)
                return Shorts.lastIndexOf(array, ((Short)o).shortValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Short)
                return Shorts.contains(array, ((Short)o).shortValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public short[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Short)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final short array[];

        protected WrappedShortArray(short array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedByteArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedByteArray create(byte array[])
        {
            return new WrappedByteArray(array);
        }

        public Byte get(int index)
        {
            return Byte.valueOf(array[index]);
        }

        public Byte set(int index, Byte element)
        {
            modCount++;
            byte old = array[index];
            array[index] = element.byteValue();
            return Byte.valueOf(old);
        }

        public int indexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Byte)
                return Bytes.indexOf(array, ((Byte)o).byteValue());
            else
                return -1;
        }

        public int lastIndexOf(Object o)
        {
            if(size() < 1)
                return -1;
            if(o instanceof Byte)
                return Bytes.lastIndexOf(array, ((Byte)o).byteValue());
            else
                return -1;
        }

        public boolean contains(Object o)
        {
            if(size() < 1)
                return false;
            if(o instanceof Byte)
                return Bytes.contains(array, ((Byte)o).byteValue());
            else
                return false;
        }

        public int size()
        {
            return array.length;
        }

        public byte[] internalToArray()
        {
            modCount++;
            return array;
        }

        public volatile Object set(int i, Object obj)
        {
            return set(i, (Byte)obj);
        }

        public volatile Object get(int i)
        {
            return get(i);
        }

        private final byte array[];

        protected WrappedByteArray(byte array[])
        {
            this.array = array;
        }
    }

    public static final class WrappedArray extends AbstractList
        implements RandomAccess
    {

        public static WrappedArray create(Object array[])
        {
            return new WrappedArray(array);
        }

        public Object get(int index)
        {
            return array[index];
        }

        public Object set(int index, Object element)
        {
            Object old = array[index];
            array[index] = element;
            modCount++;
            return old;
        }

        public int size()
        {
            return array.length;
        }

        public Object[] toArray()
        {
            return (Object[])((Object []) (array)).clone();
        }

        public Object[] internalToArray()
        {
            modCount++;
            return array;
        }

        private Object array[];

        protected WrappedArray(Object array[])
        {
            this.array = array;
        }
    }


    private Conversions()
    {
        throw new RuntimeException("Can't create instances of this class");
    }

    public static Object doWrapArray(Object object)
    {
        if(object == null)
            return null;
        Class arrayClass = object.getClass();
        if(!arrayClass.isArray())
            return object;
        if(!arrayClass.getComponentType().isPrimitive())
            return WrappedArray.create((Object[])(Object[])object);
        if(object instanceof int[])
            return WrappedIntegerArray.create((int[])(int[])object);
        if(object instanceof long[])
            return WrappedLongArray.create((long[])(long[])object);
        if(object instanceof float[])
            return WrappedFloatArray.create((float[])(float[])object);
        if(object instanceof double[])
            return WrappedDoubleArray.create((double[])(double[])object);
        if(object instanceof byte[])
            return WrappedByteArray.create((byte[])(byte[])object);
        if(object instanceof short[])
            return WrappedShortArray.create((short[])(short[])object);
        if(object instanceof boolean[])
            return WrappedBooleanArray.create((boolean[])(boolean[])object);
        if(object instanceof char[])
            return WrappedCharacterArray.create((char[])(char[])object);
        else
            throw new ArrayStoreException((new StringBuilder()).append("Unrecognised type: ").append(arrayClass.getCanonicalName()).toString());
    }

    public static Object unwrapArray(Object value)
    {
        return unwrapArray(value, java/lang/Object);
    }

    public static Object unwrapArray(Object value, Class componentType)
    {
        if(value instanceof WrappedArray)
        {
            Object result = ((Object) (((WrappedArray)value).internalToArray()));
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedIntegerArray)
        {
            Object result = ((WrappedIntegerArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedLongArray)
        {
            Object result = ((WrappedLongArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedFloatArray)
        {
            Object result = ((WrappedFloatArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedDoubleArray)
        {
            Object result = ((WrappedDoubleArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedByteArray)
        {
            Object result = ((WrappedByteArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedShortArray)
        {
            Object result = ((WrappedShortArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedBooleanArray)
        {
            Object result = ((WrappedBooleanArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(value instanceof WrappedCharacterArray)
        {
            Object result = ((WrappedCharacterArray)value).internalToArray();
            return checkComponentType(result, componentType);
        }
        if(!(value instanceof Iterable))
            return value;
        if(!componentType.isPrimitive())
        {
            Object result = ((Object) (Iterables.toArray((Iterable)value, componentType)));
            return result;
        }
        try
        {
            List list = IterableExtensions.toList((Iterable)value);
            Object result = Array.newInstance(componentType, list.size());
            for(int i = 0; i < list.size(); i++)
            {
                Object element = list.get(i);
                if(element == null)
                    throw new ArrayStoreException("Cannot store <null> in primitive arrays.");
                Array.set(result, i, element);
            }

            return result;
        }
        catch(IllegalArgumentException iae)
        {
            throw new ArrayStoreException((new StringBuilder()).append("Primitive conversion failed: ").append(iae.getMessage()).toString());
        }
    }

    private static Object checkComponentType(Object array, Class expectedComponentType)
    {
        Class actualComponentType = array.getClass().getComponentType();
        if(!expectedComponentType.isAssignableFrom(actualComponentType))
            throw new ArrayStoreException(String.format("The expected component type %s is not assignable from the actual type %s", new Object[] {
                expectedComponentType.getCanonicalName(), actualComponentType.getCanonicalName()
            }));
        else
            return array;
    }
}
