/*
 * Copyright (c) 2014 Frédéric Thomas
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package {
import com.doublefx.as3.thread.Thread;
import com.doublefx.as3.thread.api.IThread;
import com.doublefx.as3.thread.event.ThreadProgressEvent;
import com.doublefx.as3.thread.event.ThreadResultEvent;
import com.doublefx.as3.thread.util.ClassAlias;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.FileReferenceList;

import fr.kikko.lab.ShineMP3Encoder;

import mx.core.DebuggableWorker;

[SWF(width=600, height=500, backgroundColor=0x91D6FD, frameRate=30)]
public class MP3Worker extends DebuggableWorker {
    private var gui:ui;
    private var wavList:FileReferenceList;
    private var file:FileReference;
    private var _thread:IThread;

    public function MP3Worker() {
        stage.color = 0x91D6FD;

        gui = new ui();

        gui.loadbar.scaleX = 0;
        gui.x = 300;
        gui.y = 250;
        addChild(gui);

        Thread.DEFAULT_LOADER_INFO = loaderInfo;

        const aliases:Vector.<String> = Vector.<String>(["fr.kikko.lab.ShineMP3Encoder", "cmodule.shine.*"]);

        _thread = new Thread(BackWorker, "backWorker", false, aliases);

        _thread.addEventListener(ThreadProgressEvent.PROGRESS, thread_progressHandler);
        _thread.addEventListener(ThreadResultEvent.RESULT, thread_resultHandler);

        gui.loadButton.addEventListener(MouseEvent.CLICK, onLoadClicked);

        wavList = new FileReferenceList();
        wavList.addEventListener(Event.SELECT, onSelected);
    }

    protected function thread_progressHandler(event:ThreadProgressEvent):void {
        gui.loadbar.scaleX = event.current / event.total
    }

    protected function thread_resultHandler(event:ThreadResultEvent):void {
        (new FileReference()).save(event.result);
    }

    protected function onSelected(event:Event):void {
        file = wavList.fileList[0];
        file.addEventListener(Event.COMPLETE, onLoaded);

        file.load();
    }

    protected function onLoaded(event:Event):void {
        _thread.start(file.data);
    }

    protected function onLoadClicked(event:MouseEvent):void {
        wavList.browse();
    }
}
}