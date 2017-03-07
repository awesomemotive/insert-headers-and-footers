<?php
/**
 * Notices template
 */
?>
<div class="notice notice-success is-dismissible <?= $this->plugin->name ?>-notice-welcome">
	<p>Thank you for installing <?= $this->plugin->displayName ?>! <a href="<?= $setting_page ?>">Click here</a> to configure the plugin.</p>
</div>
<script type="text/javascript">
	jQuery(document).ready( function($) {
		$(document).on( 'click', '.<?= $this->plugin->name ?>-notice-welcome button.notice-dismiss', function( event ) {
			event.preventDefault();
			$.post( ajaxurl, {
				action: '<?= $this->plugin->name . '_dismiss_dashboard_notices' ?>',
				nonce: '<?= wp_create_nonce( $this->plugin->name . '-nonce' ) ?>'
			});
			$('.<?= $this->plugin->name ?>-notice-welcome').remove();
		});
	});
</script>