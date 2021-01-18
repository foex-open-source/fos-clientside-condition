/* globals apex */

var FOS = window.FOS || {};
FOS.utils = window.FOS.utils || {};

/**
 * This function evaluates the given parameters (the clientside condition) and stops the current dynamic actions
 * if the condition demands so.
 *
 * @param {object}   daContext                      Dynamic Action context as passed in by APEX
 * @param {object}   config                         Configuration object holding the clientside condition
 * @param {string}   config.type                    Type of the condition, e.g. JAVASCRIPT_EXPRESSION, LESS_THAN, ...
 * @param {function} [config.conditionFunction]     JS function which will be evaluated. If it returns false, the dynamic action will be stopped
 * @param {string}   [config.item]                  Name of an APEX page item (only set if type != JAVASCRIPT_EXPRESSION)
 * @param {string}   [config.value]                 A value, to compare the item with. In this case config.type determines the comparison operator.
 * @param {string}   [config.elseEventName]         Name of an event that will be triggered on the triggeringEelement, if condition evaluates to false
 */
FOS.utils.clientsideCondition = function (daContext, config) {

	var pluginName = 'FOS - Client-side Condition';
	apex.debug.info(pluginName, config);

	var item = config.item,
		value = config.value,
		continueExecution = true,
		elseEventName = config.elseEventName;

	if (['PAGE_IS_VALID', 'PAGE_INVALID'].includes(config.type)) {
		continueExecution = apex.page.validate();
		continueExecution = (config.type === 'PAGE_INVALID') ? !continueExecution : continueExecution;
	} else if (['PAGE_CHANGED', 'PAGE_NOT_CHANGED'].includes(config.type)) {
		continueExecution = apex.page.isChanged();
		continueExecution = (config.type === 'PAGE_NOT_CHANGED') ? !continueExecution : continueExecution;
	} else if (config.type === 'JAVASCRIPT_EXPRESSION') {
		// calling the function with the original "this"
		continueExecution = config.conditionFunction.call(daContext);
	} else {
		if (config.substitutions) {
			item = apex.util.applyTemplate(item, {
				defaultEscapeFilter: null
			});
			if (config.value) {
				value = apex.util.applyTemplate(value, {
					defaultEscapeFilter: null
				});
			}
		}
		// we use the internal APEX function for all Item =, !=, >, in list, etc conditions
		continueExecution = apex.da.testCondition(item, config.type, value);
	}

	if (continueExecution) {
		apex.debug.info('The client-side condition was evaluated to TRUE. Proceeding with execution of actions.');
	} else {
		apex.debug.info('The client-side condition was evaluated to FALSE. Stopping execution of actions.');

		// we must trigger our event first before cancelling this dynamic action, otherwise if we cancel before then our following actions will still run
		// as the cancel flags get reset by the listening dynamic actions on the ELSE trigger event
		if (elseEventName) {
			if (config.substitutions && elseEventName) {
				elseEventName = apex.util.applyTemplate(elseEventName, {
					defaultEscapeFilter: null
				});
			}
			apex.debug.info('Triggering "else" event ', elseEventName);
			// we will include the original this.data object in the else event as it may be of use
			apex.event.trigger(daContext.triggeringElement, elseEventName, daContext.data);
		}

		// as of 20.1 apex.da.cancel function exists
		if (apex.da.cancel) {
			apex.da.cancel();
		} else {
			apex.event.gCancelFlag = true;
			apex.da.gCancelActions = true;
		}
	}
};


