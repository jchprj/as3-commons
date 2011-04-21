/**
 * Copyright 2011 The original author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.ui.layout.framework.core.parser {

	import org.as3commons.ui.layout.framework.ILayout;
	import org.as3commons.ui.layout.framework.core.cell.ICell;

	/**
	 * @author Jens Struwe 16.03.2011
	 */
	public interface ILayoutParser {

		function set layout(layout : ILayout) : void;

		/*
		 * Parsing
		 */

		function prepare() : void;

		function parseCell(cell : ICell) : void;

		function finish() : ICell;

	}
}
