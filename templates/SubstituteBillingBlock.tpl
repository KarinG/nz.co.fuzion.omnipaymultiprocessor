{*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.4                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2013                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*}

  {* Add 'required' marker to billing fields in this template for front-end / online contribution and event registration forms only. *}
{if $context EQ 'front-end'}
  {assign var=reqMark value=' <span class="crm-marker" title="This field is required.">*</span>'}
{else}
  {assign var=reqMark value=''}
{/if}

{if $form.credit_card_number or $form.bank_account_number}
  <div id="payment_information">
    <fieldset class="billing_mode-group {$paymentTypeName}_info-group">
      <legend>
        {$paymentTypeLabel}
      </legend>
      {if $paymentProcessor.billing_mode & 2 and !$hidePayPalExpress}
        <div class="crm-section no-label paypal_button_info-section">
          <div class="content description">
            {ts}If you have a PayPal account, you can click the PayPal button to continue. Otherwise, fill in the credit card and billing information on this form and click <strong>Continue</strong> at the bottom of the page.{/ts}
          </div>
        </div>
        <div class="crm-section no-label {$form.$expressButtonName.name}-section">
          <div class="content description">
            {$form.$expressButtonName.html}
            <div class="description">Save time. Checkout securely. Pay without sharing your financial information. </div>
          </div>
        </div>
      {/if}
      {if $paymentFields}
        <div class="crm-section billing_mode-section {$paymentTypeName}_info-section">
          {foreach from=$paymentFields item=paymentField}
            <div class="crm-section {$form.$paymentField.name}-section">
              <div class="label">{$form.$paymentField.label} {if $form.$paymentField.is_required}{$reqMark}{/if}</div>
              <div class="content">{$form.$paymentField.html}
                {if $paymentField == 'cvv2'}{* @todo move to form assignment*}
                  <span class="cvv2-icon" title="{ts}Usually the last 3-4 digits in the signature area on the back of the card.{/ts}"> </span>
                {/if}
                {if $paymentField == 'credit_card_type'}
                  <div class="crm-credit_card_type-icons"></div>
                {/if}
              </div>
              <div class="clear"></div>
            </div>
          {/foreach}
        </div>
      {/if}
    </fieldset>
    {if $billingDetailsFields}
      {if $profileAddressFields}
        <input type="checkbox" id="billingcheckbox" value="0"> <label for="billingcheckbox">{ts}My billing address is the same as above{/ts}</label>
      {/if}
      <fieldset class="billing_name_address-group">
        <legend>{ts}Billing Name and Address{/ts}</legend>
        <div class="crm-section billing_name_address-section">
          {foreach from=$billingDetailsFields item=billingField}
            <div class="crm-section {$form.$billingField.name}-section">
              <div class="label">{$form.$billingField.label} {$reqMark}</div>
              <div class="content">{$form.$billingField.html}</div>
              <div class="clear"></div>
            </div>
          {/foreach}
        </div>
      </fieldset>
    {/if}

    {* @todo we do this purely to hack around core e-notices due to assumptions about it being debit card if not credit card *}
    {foreach from=$suppressedFields item=suppressedField}
      <input name="{$suppressedField}" type = 'hidden'> </input>
    {/foreach}
  {/if}
</div>

{if $profileAddressFields}
  <script type="text/javascript">
    {literal}

      cj( function( ) {
        // build list of ids to track changes on
        var address_fields = {/literal}{$profileAddressFields|@json_encode}{literal};
        var input_ids = {};
        var select_ids = {};
        var orig_id = field = field_name = null;

        // build input ids
        cj('.billing_name_address-section input').each(function(i){
          orig_id = cj(this).attr('id');
          field = orig_id.split('-');
          field_name = field[0].replace('billing_', '');
          if(field[1]) {
            if(address_fields[field_name]) {
              input_ids['#'+field_name+'-'+address_fields[field_name]] = '#'+orig_id;
            }
          }
        });
        if(cj('#first_name').length)
          input_ids['#first_name'] = '#billing_first_name';
        if(cj('#middle_name').length)
          input_ids['#middle_name'] = '#billing_middle_name';
        if(cj('#last_name').length)
          input_ids['#last_name'] = '#billing_last_name';

        // build select ids
        cj('.billing_name_address-section select').each(function(i){
          orig_id = cj(this).attr('id');
          field = orig_id.split('-');
          field_name = field[0].replace('billing_', '').replace('_id', '');
          if(field[1]) {
            if(address_fields[field_name]) {
              select_ids['#'+field_name+'-'+address_fields[field_name]] = '#'+orig_id;
            }
          }
        });

        // detect if billing checkbox should default to checked
        var checked = true;
        for(var id in input_ids) {
          var orig_id = input_ids[id];
          if(cj(id).val() != cj(orig_id).val()) {
            checked = false;
            break;
          }
        }
        for(var id in select_ids) {
          var orig_id = select_ids[id];
          if(cj(id).val() != cj(orig_id).val()) {
            checked = false;
            break;
          }
        }
        if(checked) {
          cj('#billingcheckbox').attr('checked', 'checked');
          cj('.billing_name_address-group').hide();
        }

        // onchange handlers for non-billing fields
        for(var id in input_ids) {
          var orig_id = input_ids[id];
          cj(id).change(function(){
            var id = '#'+cj(this).attr('id');
            var orig_id = input_ids[id];

            // if billing checkbox is active, copy other field into billing field
            if(cj('#billingcheckbox').attr('checked')) {
              cj(orig_id).val( cj(id).val() );
            };
          });
        };
        for(var id in select_ids) {
          var orig_id = select_ids[id];
          cj(id).change(function(){
            var id = '#'+cj(this).attr('id');
            var orig_id = select_ids[id];

            // if billing checkbox is active, copy other field into billing field
            if(cj('#billingcheckbox').attr('checked')) {
              cj(orig_id+' option').removeAttr('selected');
              cj(orig_id+' option[value="'+cj(id).val()+'"]').attr('selected', 'selected');
            };

            if(orig_id == '#billing_country_id-5') {
              cj(orig_id).change();
            }
          });
        };


        // toggle show/hide
        cj('#billingcheckbox').click(function(){
          if(this.checked) {
            cj('.billing_name_address-group').hide(200);

            // copy all values
            for(var id in input_ids) {
              var orig_id = input_ids[id];
              cj(orig_id).val( cj(id).val() );
            };
            for(var id in select_ids) {
              var orig_id = select_ids[id];
              cj(orig_id+' option').removeAttr('selected');
              cj(orig_id+' option[value="'+cj(id).val()+'"]').attr('selected', 'selected');
            };
          } else {
            cj('.billing_name_address-group').show(200);
          }
        });
        {/literal}
          {include file='CRM/CreditCard.js.tpl'}
        {literal}

      });
    {/literal}
  </script>
{/if}

