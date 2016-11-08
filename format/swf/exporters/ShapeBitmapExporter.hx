package format.swf.exporters;

import haxe.ds.Option;

import format.swf.exporters.core.ShapeCommand;
import openfl.geom.Matrix;

class ShapeBitmapExporter
{
    
    public static function process(exporter:ShapeCommandExporter):Array<{id:Int, transform:Matrix}> {
        var bitmaps = [];
        var commands = exporter.commands.copy();
        var eligable = commands != null && commands.length > 0 && commands.length % 9 == 0;
        if(!eligable) return null;
        
        while(commands.length > 0){
            switch(processNextBitmap(commands.splice(0, 9))){
                case Some(bitmap) : bitmaps.push(bitmap);
                case None : return null;
            }
        }
        return bitmaps;
    }
    
    private static function processNextBitmap(commands:Array<ShapeCommand>):Option<{id:Int, transform:Matrix}> {
        if(commands.length != 9) return null;
        
        var valid = true;
        var bitmapId:Int = 0;
        var vertices:Array<{x:Float, y:Float}> = [];
        var localMatrix:Matrix = new Matrix();
        localMatrix.identity();
        var positionX = 0.0;
        var positionY = 0.0;
        var index = 0;
        
        for(command in commands){
            switch(command){
                case LineStyle(null, null, null, null, null, null, null, null) if(index == 0) : null;
                case EndFill if (index == 1 || index == 8) : null;
                case BeginBitmapFill(bid, matrix, repeat, smooth) if (index == 2) : 
                    bitmapId = bid;
                    if(matrix != null) localMatrix = matrix;
                case MoveTo(x, y) if(index == 3) : 
                    positionX = x;
                    positionY = y;
                case LineTo(x, y) if(index > 3 && index < 8) : vertices.push({x:x, y:y});
                case EndFill if (index == 8) : null;
                default : return None;
            }
            index++;
        }
        return Some({id:bitmapId, transform:localMatrix});	
    }
}