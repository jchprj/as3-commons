/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.setup {
	
	import org.as3commons.logging.ILogSetup;
	import org.as3commons.logging.Logger;
	import org.as3commons.logging.setup.SimpleTargetSetup;
	
	/**
	 * The <code>RegExpSetup</code> allows to filter different <code>ILogSetup</code>
	 * instances to differently named loggers.
	 * 
	 * <p>This setup allows to restrict the logging to just work with certain loggers
	 * based on the name of it. This setup will check if the name of the logger really
	 * matches the RegExp given for the child setup. Just if it passes the name
	 * test the logger will be applied, here is a short example for matching
	 * just loggers starting with <code>"org.as3commons"</code>:</p>
	 * 
	 * <listing>
	 *   LOGGER_FACTORY.setup = new RegExpSetup()
	 *         .addRule(/^org\.as3commons\./, new SimpleTargetSetup(TRACE_TARGET) );
	 * </listing>
	 * 
	 * <p>The former example will trace <b>nothing but</b> the statements passed
	 * to loggers that start with <code>"org.as3commons"</code>.</p>
	 * 
	 * <p>The setup offers two other methods that allow to write the former code
	 * shorter.</p>
	 * 
	 * <listing>
	 *   LOGGER_FACTORY.setup = new RegExpSetup()
	 *         // uses the trace target to all code in org.as3commons
	 *         .addTargetRule(/^org\.as3commons\./, TRACE_TARGET );
	 *         // uses just the debug level to all code in com.mycompany
	 *         .addTargetRule(/^com\.mycompany\./, TRACE_TARGET, LogSetupLevel.DEBUG_ONLY );
	 *         // overwrites the first definition by not allowing any output at
	 *         // org.as3commons.logging
	 *         .addNoLogRule(/^org\.as3commons\.logging\./ );
	 * </listing>
	 * 
	 * <p></p>
	 * 
	 * @author Martin Heidegger
	 * @since 2
	 */
	public class RegExpSetup implements ILogSetup {
		
		/** Setup to be used for addNoLogRule */
		private static const NO_LOG_SETUP: ILogSetup = new SimpleTargetSetup(null);
		
		/** First rule of the setup. */
		private var _firstRule: RegExpRule;
		
		/** Last rule of the setup. */
		private var _lastRule: RegExpRule;
		
		/**
		 * Constructs a new <code>RegExpSetup</code>.
		 */
		public function RegExpSetup() {}
		
		/**
		 * Adds a rule which defines when to use a setup for a logger according
		 * to the loggers name.
		 * 
		 * @param classRule The rule to which the name of the logger has to match. 
		 * @param setup Setup to be applied to the loggers that match.
		 * @param personRule Rule to which the person has to match. (if null, all persons will match)
		 * @return This setup instance.
		 */
		public function addRule( classRule:RegExp, setup:ILogSetup, personRule:RegExp=null ): RegExpSetup {
			var newRule: RegExpRule = new RegExpRule(classRule, setup, personRule);
			if( _lastRule ) {
				_lastRule.next = newRule;
			} else {
				_firstRule = newRule;
			}
			_lastRule = newRule;
			return this;
		}
		
		/**
		 * Adds a rule which defines when to use a certain <code>ILogTarget</code>
		 * with loggers.
		 * 
		 * <p>Its a shorthand method of:</p>
		 * <listing>addRule([rule], new LevelTargetSetup( [target], [level] ) );</listing>
		 * 
		 * @param rule The rule to which the name of the logger has to match.
		 * @param target Target used for these loggers.
		 * @param level Level that can restrict for which levels it should be used.
		 * @param personRule Rule to which the person has to match. (if null, all persons will match)
		 * @return This setup instance.
		 */
		public function addTargetRule(rule:RegExp, target:ILogTarget, level:LogSetupLevel=null, personRule:RegExp=null): RegExpSetup {
			return addRule(
				rule,
				level ? new LevelTargetSetup(target, level) : new SimpleTargetSetup(target),
				personRule
			);
		}
		
		/**
		 * Adds a rule which defines when to remove loggers added by previous statements.
		 * 
		 * <p>Its a shorthand method of:</p>
		 * <listing>addRule([rule], new SimpleTargetSetup( null ) );</listing>
		 * 
		 * @param rule The rule to which the name of the logger has to match.
		 * @param regexp 
		 * @return This setup instance.
		 */
		public function addNoLogRule(rule:RegExp): RegExpSetup {
			return addRule(rule,NO_LOG_SETUP);
		}
		
		/**
		 * @inheritDoc
		 */
		public function applyTo(logger:Logger):void {
			logger.allTargets = null;
			var current: RegExpRule = _firstRule;
			var name: String = logger.name;
			var person: String = logger.person;
			while( current ) {
				// Apply the setups just to matching targets
				if( current.classRule.test(name)
					&& (!current.personRule || current.personRule.test(person)) ) {
					current.setup.applyTo(logger);
				}
				current = current.next;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			var current: RegExpRule = _firstRule;
			while( current ) {
				current = current.dispose();
			}
			_firstRule = null;
		}
	}
}

import org.as3commons.logging.ILogSetup;

internal class RegExpRule {
	public var classRule: RegExp;
	public var personRule: RegExp;
	public var setup: ILogSetup;
	public var next: RegExpRule;
	
	public function RegExpRule(classRule:RegExp, setup:ILogSetup, personRule:RegExp) {
		this.classRule = classRule;
		this.setup = setup;
		this.personRule = personRule;
	}
	
	public function dispose():RegExpRule {
		var result: RegExpRule = next;
		classRule = null;
		personRule = null;
		setup = null;
		next = null;
		return result;
	}
}